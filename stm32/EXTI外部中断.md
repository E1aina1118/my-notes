# EXTI外部终端

## 中断系统

- **中断**：在主程序运行过程中，出现了特定的中断触发条件（终端源），使得CPU暂停当前正在运行的程序，转而去处理中断程序，处理完成后又返回原来被暂停的位置继续运行

<!--more-->

- **中断优先级**：当有多个中断源同时申请中断时，CPU会根据中断源的轻重缓急进行裁决，优先响应更加紧急的中断源
- **中断嵌套**：当一个中断程序承载运行时，又有新的更高级的中断源申请中断，CPU再次暂停当前中断程序，转而去处理新的中断程序，处理完成后依次进行返回。

![image-20240809212854214](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809212854214.png)

## NVIC

### NVIC简介

NVIC(Nested vectoredinterrupt controller)，即嵌套向量中断控制器。

内核中，会有NVIC对cpu进行辅助，对任务的优先级进行处理。

![image-20240809215942622](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809215942622.png)

NVIC优先级分组，**分为抢占优先级**(pre-emption priority)和**响应优先级**(subpriority)。

- **抢占**，是指打断其他中断的属性，即因为具有这个属性会出现嵌套中断（在执行中断服务函数A 的过程中被中断B 打断，执行完中断服务函数B 再继续执行中断服务函数A），抢占属性由`NVIC_IRQChannelPreemptionPriority` 的参数配置。
- **响应**属性则应用在抢占属性相同的情况下，当两个中断向量的抢占优先级相同时，如果两个中断同时到达， 则先处理响应优先级高的中断， 响应属性由`NVIC_IRQChannelSubPriority` 参数配置。

例如，现在有三个中断向量：

![image-20240809225717773](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809225717773.png)

若内核正在执行C 的中断服务函数，则它能被抢占优先级更高的中断A 打断，由于B 和C 的抢占优先级相同，所以C 不能被B 打断。但如果B 和C 中断是同时到达的，内核就会首先响应响应优先级别更高的B 中断（高优先级的抢占优先级是可以打断正在进行的低抢占优先级中断的，而抢占优先级相同的中断，高优先级的响应优先级不可以打断低响应优先级的中断）。

## EXTI

### 简介

- EXTI(Extern Interrupt) 外部中断

- EXTI可以监测指定GPIO口的电平信号，当其指定的GPIO口产生电平变化时，EXTI将立即想NVIC发出中断申请，经过NVIC裁决后即可中断CPU主程序，使CPU执行EXTI对应的中断程序
- 支持的出发方式：上升沿/下降沿/双边沿/软件触发
- 支持的GPIO口：所有GPIO口，但相同的Pin不能同时触发中断
- 通道数：16个GPIO_Pin，外加PVD输出、RTC闹钟、USB唤醒、以太网唤醒
- 触发响应方式：中断响应/事件响应

### EXTI的基本结构

![image-20240809230216358](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809230216358.png)

## 项目实现

### 对射式红外传感器计次

#### 接线图

![image-20240809232608257](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809232608257.png)

#### 驱动文件

添加驱动文件

![image-20240809233207964](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809233207964.png)

打开`CountSensor.c`，首先写一个外部中断初始化函数。

```c
void CountSensor_Init(void)
{
	// ...
}
```

配置外部中断的流程：

首先，理顺思路，先查看外部中断的原理图：

![image-20240809233520868](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809233520868.png)

我们需要把外部中断，从**GPIO**到**NVIC**这一路中出现的外设模块都配置好，**把信号电路打通**。

这里涉及的外设比较多，有**RCC**、**GPIO**、**AFIO**、**EXTI**、**NVIC**

**具体步骤：**

1. 配置RCC，把涉及的外设的时钟都打开，外设没有时钟是没法工作的。
2. 配置GPIO，选择端口为输入模式
3. 配置AFIO，选择用的这一路的GPIO，连接到后面的EXTI
4. 配置EXTI，选择边沿触发方式，比如上升沿、下降沿或者双边沿。选择触发响应方式，可以选择中断响应和事件响应（一般都是中断响应）
5. 配置NVIC，给这个中断选择一个合适的优先级
6. 最后，通过NVIC，外部中断信号就能进入CPU了

#### 编辑`CountSensor.c`

```c
#include "stm32f10x.h"                  // Device header

uint16_t CountSensor_Count;

void CountSensor_Init(void)
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);
	// EXTI和NVIC不需要开启时钟，其中NVIC为内核外设，默认开启
	// RCC管的都是内核外的外设
	
	// GPIO初始化，推荐为浮空输入或上拉输入或带下拉输入
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPD;
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_14;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOB, &GPIO_InitStructure);
	
	GPIO_EXTILineConfig(GPIO_PortSourceGPIOB,GPIO_PinSource14);
	
	// EXTI配置
	EXTI_InitTypeDef EXTI_InitStructure;
	EXTI_InitStructure.EXTI_Line = EXTI_Line14;// 将EXTI第14线路
	EXTI_InitStructure.EXTI_LineCmd = ENABLE;// 开启中断
	EXTI_InitStructure.EXTI_Mode = EXTI_Mode_Interrupt;// 配置为中断模式
	EXTI_InitStructure.EXTI_Trigger = EXTI_Trigger_Rising;// 下降沿触发
	EXTI_Init(&EXTI_InitStructure);
	
	// NVIC配置
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);
	
	NVIC_InitTypeDef NVIC_InitStructure;
	NVIC_InitStructure.NVIC_IRQChannel = EXTI15_10_IRQn;
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority =1;
	NVIC_InitStructure.NVIC_IRQChannelSubPriority =1;
	NVIC_Init(&NVIC_InitStructure);
}

uint16_t CountSensor_Get(void)// 计数函数
{
	return CountSensor_Count;
}

void EXTI15_10_IRQHandler(void)
{
	if(EXTI_GetITStatus(EXTI_Line14) == SET)// 如果14引脚标志位为SET，则计数加一
	{
		CountSensor_Count ++;
		EXTI_ClearITPendingBit(EXTI_Line14);// 清除当前标志位，避免死循环
	}
}

```

#### 编辑`CountSensor.h`文件

```c
#ifndef __COUNT_SENSOR_H
#define __COUNT_SENSOR_H

void CountSensor_Init(void);
uint16_t CountSensor_Get(void);

#endif

```

声明两个函数即可

#### 编辑`main.c`文件

```c
#include "stm32f10x.h"                  // Device header
#include "delay.h"
#include "OLED.h"
#include "CountSensor.h"

int main(void)
{
	OLED_Init();
	CountSensor_Init();
	
	OLED_ShowString(1,1,"Count:");
	
	while(1)
	{
	OLED_ShowNum(1,7,CountSensor_Get(),5);
	}
}

```

编译，下载即可。

### 旋转编码器计次

#### 接线图

![image-20240812212458292](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240812212458292.png)

#### 驱动文件

![image-20240812213947254](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240812213947254.png)





**正向旋转时的波形**：

![](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240812214203776.png)

**反向旋转时的波形**：

![image-20240812214246452](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240812214246452.png)

因此，当一相出现下降沿时，检测另一相的电平即可判断正反转。此编码器，正转时是高电平，反转时是低电平。

正反是相对的，可以自己定义。

#### 编辑`Encoder.c`

中断函数可以在启动文件找到：

![](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240812215554931.png)

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240812215654618.png" alt="image-20240812215654618" style="zoom: 80%;" />



```c
#include "stm32f10x.h"                  // Device header

int16_t Encoder_Count;					//全局变量，用于计数旋转编码器的增量值

/**
  * 函    数：旋转编码器初始化
  * 参    数：无
  * 返 回 值：无
  */
void Encoder_Init(void)
{
	/*开启时钟*/
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);		//开启GPIOB的时钟
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);		//开启AFIO的时钟，外部中断必须开启AFIO的时钟
	
	/*GPIO初始化*/
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPU;
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0 | GPIO_Pin_1;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOB, &GPIO_InitStructure);						//将PB0和PB1引脚初始化为上拉输入
	
	/*AFIO选择中断引脚*/
	GPIO_EXTILineConfig(GPIO_PortSourceGPIOB, GPIO_PinSource0);//将外部中断的0号线映射到GPIOB，即选择PB0为外部中断引脚
	GPIO_EXTILineConfig(GPIO_PortSourceGPIOB, GPIO_PinSource1);//将外部中断的1号线映射到GPIOB，即选择PB1为外部中断引脚
	
	/*EXTI初始化*/
	EXTI_InitTypeDef EXTI_InitStructure;						//定义结构体变量
	EXTI_InitStructure.EXTI_Line = EXTI_Line0 | EXTI_Line1;		//选择配置外部中断的0号线和1号线
	EXTI_InitStructure.EXTI_LineCmd = ENABLE;					//指定外部中断线使能
	EXTI_InitStructure.EXTI_Mode = EXTI_Mode_Interrupt;			//指定外部中断线为中断模式
	EXTI_InitStructure.EXTI_Trigger = EXTI_Trigger_Falling;		//指定外部中断线为下降沿触发
	EXTI_Init(&EXTI_InitStructure);								//将结构体变量交给EXTI_Init，配置EXTI外设
	
	/*NVIC中断分组*/
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);				//配置NVIC为分组2
																//即抢占优先级范围：0~3，响应优先级范围：0~3
																//此分组配置在整个工程中仅需调用一次
																//若有多个中断，可以把此代码放在main函数内，while循环之前
																//若调用多次配置分组的代码，则后执行的配置会覆盖先执行的配置
	
	/*NVIC配置*/
	NVIC_InitTypeDef NVIC_InitStructure;						//定义结构体变量
	NVIC_InitStructure.NVIC_IRQChannel = EXTI0_IRQn;			//选择配置NVIC的EXTI0线
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;				//指定NVIC线路使能
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 1;	//指定NVIC线路的抢占优先级为1
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 1;			//指定NVIC线路的响应优先级为1
	NVIC_Init(&NVIC_InitStructure);								//将结构体变量交给NVIC_Init，配置NVIC外设

	NVIC_InitStructure.NVIC_IRQChannel = EXTI1_IRQn;			//选择配置NVIC的EXTI1线
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;				//指定NVIC线路使能
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 1;	//指定NVIC线路的抢占优先级为1
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 2;			//指定NVIC线路的响应优先级为2
	NVIC_Init(&NVIC_InitStructure);								//将结构体变量交给NVIC_Init，配置NVIC外设
}

/**
  * 函    数：旋转编码器获取增量值
  * 参    数：无
  * 返 回 值：自上此调用此函数后，旋转编码器的增量值
  */
int16_t Encoder_Get(void)
{
	/*使用Temp变量作为中继，目的是返回Encoder_Count后将其清零*/
	/*在这里，也可以直接返回Encoder_Count
	  但这样就不是获取增量值的操作方法了
	  也可以实现功能，只是思路不一样*/
	int16_t Temp;
	Temp = Encoder_Count;
	Encoder_Count = 0;
	return Temp;
}

/**
  * 函    数：EXTI0外部中断函数
  * 参    数：无
  * 返 回 值：无
  * 注意事项：此函数为中断函数，无需调用，中断触发后自动执行
  *           函数名为预留的指定名称，可以从启动文件复制
  *           请确保函数名正确，不能有任何差异，否则中断函数将不能进入
  */
void EXTI0_IRQHandler(void)
{
	if (EXTI_GetITStatus(EXTI_Line0) == SET)		//判断是否是外部中断0号线触发的中断
	{
		/*如果出现数据乱跳的现象，可再次判断引脚电平，以避免抖动*/
		if (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_0) == 0)
		{
			if (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_1) == 0)		//PB0的下降沿触发中断，此时检测另一相PB1的电平，目的是判断旋转方向
			{
				Encoder_Count --;					//此方向定义为反转，计数变量自减
			}
		}
		EXTI_ClearITPendingBit(EXTI_Line0);			//清除外部中断0号线的中断标志位
													//中断标志位必须清除
													//否则中断将连续不断地触发，导致主程序卡死
	}
}

/**
  * 函    数：EXTI1外部中断函数
  * 参    数：无
  * 返 回 值：无
  * 注意事项：此函数为中断函数，无需调用，中断触发后自动执行
  *           函数名为预留的指定名称，可以从启动文件复制
  *           请确保函数名正确，不能有任何差异，否则中断函数将不能进入
  */
void EXTI1_IRQHandler(void)
{
	if (EXTI_GetITStatus(EXTI_Line1) == SET)		//判断是否是外部中断1号线触发的中断
	{
		/*如果出现数据乱跳的现象，可再次判断引脚电平，以避免抖动*/
		if (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_1) == 0)
		{
			if (GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_0) == 0)		//PB1的下降沿触发中断，此时检测另一相PB0的电平，目的是判断旋转方向
			{
				Encoder_Count ++;					//此方向定义为正转，计数变量自增
			}
		}
		EXTI_ClearITPendingBit(EXTI_Line1);			//清除外部中断1号线的中断标志位
													//中断标志位必须清除
													//否则中断将连续不断地触发，导致主程序卡死
	}
}

```

#### 编辑`Encoder.h`

```c
#ifndef __ENCODER_H
#define __ENCODER_H

void Encoder_Init(void);
int16_t Encoder_Get(void);

#endif

```

#### 编辑`main.c`

```c
#include "stm32f10x.h"                  // Device header
#include "Delay.h"
#include "OLED.h"
#include "Encoder.h"

int16_t Num;			//定义待被旋转编码器调节的变量

int main(void)
{
	/*模块初始化*/
	OLED_Init();		//OLED初始化
	Encoder_Init();		//旋转编码器初始化
	
	/*显示静态字符串*/
	OLED_ShowString(1, 1, "Num:");			//1行1列显示字符串Num:
	
	while (1)
	{
		Num += Encoder_Get();				//获取自上此调用此函数后，旋转编码器的增量值，并将增量值加到Num上
		OLED_ShowSignedNum(1, 5, Num, 5);	//显示Num
	}
}

```

编译，下载。

## 结语

- 不要在中断函数中执行耗时过长的操作，会造成主程序的严重阻塞。
- 尽量不要在中断函数中调用硬件相关的函数，可能与主函数造成冲突。尽量使用变量、标志位进行信息传递。

















> 参考文献：
>
> - [【STM32】NVIC 中断优先级管理，抢占优先级，响应优先级，中断寄存器_抢占优先级和响应优先级的区别和联系-CSDN博客](https://blog.csdn.net/weixin_36815313/article/details/120306031)