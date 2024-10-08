# TIM定时器

## TIM简介

- **TIM(Timer)定时器**
- 定时器可以对输入的时钟进行**计数**，并在计数值达到设定值时触发中断
- 16位计数器、预分频器、自动重装寄存器的**时基单元**，在72MHz计数时钟下可以实现最大59.65s的定时。

<!--more-->

- 不仅具备基本的定时中断功能，而且还包含内外时钟源选择、输入捕获、输出比较、编码器接口、主从触发模式等多种功能。
- 根据复杂度和应用场景分为了高级定时器、通用定时器、基本定时器三种类型。

> ​	可以看出来，定时器就是一个**计数器**，当这个计数器的输入是一个**准确可靠**的**基准时钟**的时候，在对这个基准时钟进行计数的过程，实际上就是计时的过程。
>
> ​	2的16次方是65536，也就是如果预分频器设置最大，自动重装也设置最大，定时器的最大定时时间就是**59.65秒**(1/(72M/65536/65536))，接近1分钟。stm32还支持级联操作，将一个定时器的输出当作零另一个定时器的输入，可以延长至8千年。

### 定时器类型

![image-20240812225349819](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240812225349819.png)

> 对于**STM32F103C8T6**定时器资源：TIM1、TIM2、TIM3、TIM4

### 原理图

**基本定时器**

![image-20240812225924366](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240812225924366.png)

**定时中断基本结构**

![image-20240812231747227](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240812231747227.png)

**预分频器**

![image-20240812232136793](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240812232136793.png)

> 计数器计数频率： CK_CNT = CK_PSC / (PSC + 1)

**计数器时序**

![image-20240812232416100](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240812232416100.png)

> 计数器溢出频率：CK_CNT_OV = CK_CNT / (ARR+1) = CK_PSC / (PSC + 1) / (ARR + 1)

## 项目实现

### 定时器定时中断

#### 接线图

![image-20240812234005088](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240812234005088.png)

参考定时中断基本结构图，逐一打通信号：

1. RCC开启时钟
2. 选择时基单元时钟源，这里选择内部时钟源
3. 配置时基单元（包括预分频器、自动重装器、计数模式等）
4. 配置输出中断控制，允许更新中断输出到NVIC
5. 配置NVIC，在NVIC中打开定时器中断的通道，并分配一个优先级
6. 运行控制

**时钟源选择**

```c
void TIM_InternalClockConfig(TIM_TypeDef* TIMx);
void TIM_ITRxExternalClockConfig(TIM_TypeDef* TIMx, uint16_t TIM_InputTriggerSource);
void TIM_TIxExternalClockConfig(TIM_TypeDef* TIMx, uint16_t TIM_TIxExternalCLKSource,
                                uint16_t TIM_ICPolarity, uint16_t ICFilter);
void TIM_ETRClockMode1Config(TIM_TypeDef* TIMx, uint16_t TIM_ExtTRGPrescaler, uint16_t TIM_ExtTRGPolarity,
                             uint16_t ExtTRGFilter);
void TIM_ETRClockMode2Config(TIM_TypeDef* TIMx, uint16_t TIM_ExtTRGPrescaler, 
                             uint16_t TIM_ExtTRGPolarity, uint16_t ExtTRGFilter);
void TIM_ETRConfig(TIM_TypeDef* TIMx, uint16_t TIM_ExtTRGPrescaler, uint16_t TIM_ExtTRGPolarity,
                   uint16_t ExtTRGFilter);
```

**时基单元**

```c
void TIM_TimeBaseStructInit(TIM_TimeBaseInitTypeDef* TIM_TimeBaseInitStruct);
```

**中断输出控制**

```c
void TIM_ITConfig(TIM_TypeDef* TIMx, uint16_t TIM_IT, FunctionalState NewState);
```

**运行控制**

```c
void TIM_Cmd(TIM_TypeDef* TIMx, FunctionalState NewState);
```

#### 编辑`Timer.c`

```c
#include "stm32f10x.h"                  // Device header

/**
  * 函    数：定时中断初始化
  * 参    数：无
  * 返 回 值：无
  */
void Timer_Init(void)
{
	/*开启时钟*/
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2, ENABLE);			//开启TIM2的时钟
	
	/*配置时钟源*/
	TIM_InternalClockConfig(TIM2);		//选择TIM2为内部时钟，若不调用此函数，TIM默认也为内部时钟
	
	/*时基单元初始化*/
	TIM_TimeBaseInitTypeDef TIM_TimeBaseInitStructure;				//定义结构体变量
	TIM_TimeBaseInitStructure.TIM_ClockDivision = TIM_CKD_DIV1;		//时钟分频，选择不分频，此参数用于配置滤波器时钟，不影响时基单元功能
	TIM_TimeBaseInitStructure.TIM_CounterMode = TIM_CounterMode_Up;	//计数器模式，选择向上计数
	TIM_TimeBaseInitStructure.TIM_Period = 10000 - 1;				//计数周期，即ARR的值
	TIM_TimeBaseInitStructure.TIM_Prescaler = 7200 - 1;				//预分频器，即PSC的值
	TIM_TimeBaseInitStructure.TIM_RepetitionCounter = 0;			//重复计数器，高级定时器才会用到
	TIM_TimeBaseInit(TIM2, &TIM_TimeBaseInitStructure);				//将结构体变量交给TIM_TimeBaseInit，配置TIM2的时基单元	
	
	/*中断输出配置*/
	TIM_ClearFlag(TIM2, TIM_FLAG_Update);						//清除定时器更新标志位
																//TIM_TimeBaseInit函数末尾，手动产生了更新事件
																//若不清除此标志位，则开启中断后，会立刻进入一次中断
																//如果不介意此问题，则不清除此标志位也可
	
	TIM_ITConfig(TIM2, TIM_IT_Update, ENABLE);					//开启TIM2的更新中断
	
	/*NVIC中断分组*/
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);				//配置NVIC为分组2
																//即抢占优先级范围：0~3，响应优先级范围：0~3
																//此分组配置在整个工程中仅需调用一次
																//若有多个中断，可以把此代码放在main函数内，while循环之前
																//若调用多次配置分组的代码，则后执行的配置会覆盖先执行的配置
	
	/*NVIC配置*/
	NVIC_InitTypeDef NVIC_InitStructure;						//定义结构体变量
	NVIC_InitStructure.NVIC_IRQChannel = TIM2_IRQn;				//选择配置NVIC的TIM2线
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;				//指定NVIC线路使能
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 2;	//指定NVIC线路的抢占优先级为2
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 1;			//指定NVIC线路的响应优先级为1
	NVIC_Init(&NVIC_InitStructure);								//将结构体变量交给NVIC_Init，配置NVIC外设
	
	/*TIM使能*/
	TIM_Cmd(TIM2, ENABLE);			//使能TIM2，定时器开始运行
}

/* 定时器中断函数，可以复制到使用它的地方
void TIM2_IRQHandler(void)
{
	if (TIM_GetITStatus(TIM2, TIM_IT_Update) == SET)
	{
		
		TIM_ClearITPendingBit(TIM2, TIM_IT_Update);
	}
}
*/

```

#### 编辑`Timer.h`

```c
#ifndef __TIMER_H
#define __TIMER_H

void Timer_Init(void);

#endif

```

#### 编辑`main.c`

```c
#include "stm32f10x.h"                  // Device header
#include "Delay.h"
#include "OLED.h"
#include "Timer.h"

uint16_t Num;			//定义在定时器中断里自增的变量

int main(void)
{
	/*模块初始化*/
	OLED_Init();		//OLED初始化
	Timer_Init();		//定时中断初始化
	
	/*显示静态字符串*/
	OLED_ShowString(1, 1, "Num:");			//1行1列显示字符串Num:
	
	while (1)
	{
		OLED_ShowNum(1, 5, Num, 5);			//不断刷新显示Num变量
	}
}

/**
  * 函    数：TIM2中断函数
  * 参    数：无
  * 返 回 值：无
  * 注意事项：此函数为中断函数，无需调用，中断触发后自动执行
  *           函数名为预留的指定名称，可以从启动文件复制
  *           请确保函数名正确，不能有任何差异，否则中断函数将不能进入
  */
void TIM2_IRQHandler(void)
{
	if (TIM_GetITStatus(TIM2, TIM_IT_Update) == SET)		//判断是否是TIM2的更新事件触发的中断
	{
		Num ++;												//Num变量自增，用于测试定时中断
		TIM_ClearITPendingBit(TIM2, TIM_IT_Update);			//清除TIM2更新事件的中断标志位
															//中断标志位必须清除
															//否则中断将连续不断地触发，导致主程序卡死
	}
}

```

### 定时器外部时钟

#### 接线图

![image-20240813004222745](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240813004222745.png)

#### 编辑`Timer.c`

```c
#include "stm32f10x.h"                  // Device header

/**
  * 函    数：定时中断初始化
  * 参    数：无
  * 返 回 值：无
  * 注意事项：此函数配置为外部时钟，定时器相当于计数器
  */
void Timer_Init(void)
{
	/*开启时钟*/
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2, ENABLE);			//开启TIM2的时钟
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);			//开启GPIOA的时钟
	
	/*GPIO初始化*/
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPU;
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOA, &GPIO_InitStructure);						//将PA0引脚初始化为上拉输入
	
	/*外部时钟配置*/
	TIM_ETRClockMode2Config(TIM2, TIM_ExtTRGPSC_OFF, TIM_ExtTRGPolarity_NonInverted, 0x0F);
																//选择外部时钟模式2，时钟从TIM_ETR引脚输入
																//注意TIM2的ETR引脚固定为PA0，无法随意更改
																//最后一个滤波器参数加到最大0x0F，可滤除时钟信号抖动
	
	/*时基单元初始化*/
	TIM_TimeBaseInitTypeDef TIM_TimeBaseInitStructure;				//定义结构体变量
	TIM_TimeBaseInitStructure.TIM_ClockDivision = TIM_CKD_DIV1;		//时钟分频，选择不分频，此参数用于配置滤波器时钟，不影响时基单元功能
	TIM_TimeBaseInitStructure.TIM_CounterMode = TIM_CounterMode_Up;	//计数器模式，选择向上计数
	TIM_TimeBaseInitStructure.TIM_Period = 10 - 1;					//计数周期，即ARR的值
	TIM_TimeBaseInitStructure.TIM_Prescaler = 1 - 1;				//预分频器，即PSC的值
	TIM_TimeBaseInitStructure.TIM_RepetitionCounter = 0;			//重复计数器，高级定时器才会用到
	TIM_TimeBaseInit(TIM2, &TIM_TimeBaseInitStructure);				//将结构体变量交给TIM_TimeBaseInit，配置TIM2的时基单元	
	
	/*中断输出配置*/
	TIM_ClearFlag(TIM2, TIM_FLAG_Update);						//清除定时器更新标志位
																//TIM_TimeBaseInit函数末尾，手动产生了更新事件
																//若不清除此标志位，则开启中断后，会立刻进入一次中断
																//如果不介意此问题，则不清除此标志位也可
																
	TIM_ITConfig(TIM2, TIM_IT_Update, ENABLE);					//开启TIM2的更新中断
	
	/*NVIC中断分组*/
	NVIC_PriorityGroupConfig(NVIC_PriorityGroup_2);				//配置NVIC为分组2
																//即抢占优先级范围：0~3，响应优先级范围：0~3
																//此分组配置在整个工程中仅需调用一次
																//若有多个中断，可以把此代码放在main函数内，while循环之前
																//若调用多次配置分组的代码，则后执行的配置会覆盖先执行的配置
	
	/*NVIC配置*/
	NVIC_InitTypeDef NVIC_InitStructure;						//定义结构体变量
	NVIC_InitStructure.NVIC_IRQChannel = TIM2_IRQn;				//选择配置NVIC的TIM2线
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;				//指定NVIC线路使能
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 2;	//指定NVIC线路的抢占优先级为2
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 1;			//指定NVIC线路的响应优先级为1
	NVIC_Init(&NVIC_InitStructure);								//将结构体变量交给NVIC_Init，配置NVIC外设
	
	/*TIM使能*/
	TIM_Cmd(TIM2, ENABLE);			//使能TIM2，定时器开始运行
}

/**
  * 函    数：返回定时器CNT的值
  * 参    数：无
  * 返 回 值：定时器CNT的值，范围：0~65535
  */
uint16_t Timer_GetCounter(void)
{
	return TIM_GetCounter(TIM2);	//返回定时器TIM2的CNT
}

/* 定时器中断函数，可以复制到使用它的地方
void TIM2_IRQHandler(void)
{
	if (TIM_GetITStatus(TIM2, TIM_IT_Update) == SET)
	{
		
		TIM_ClearITPendingBit(TIM2, TIM_IT_Update);
	}
}
*/

```

#### 编辑`Timer.h`

```c
#ifndef __TIMER_H
#define __TIMER_H

void Timer_Init(void);
uint16_t Timer_GetCounter(void);

#endif

```

#### 编辑`main.c`

```c
#include "stm32f10x.h"                  // Device header
#include "Delay.h"
#include "OLED.h"
#include "Timer.h"

uint16_t Num;			//定义在定时器中断里自增的变量

int main(void)
{
	/*模块初始化*/
	OLED_Init();		//OLED初始化
	Timer_Init();		//定时中断初始化
	
	/*显示静态字符串*/
	OLED_ShowString(1, 1, "Num:");			//1行1列显示字符串Num:
	OLED_ShowString(2, 1, "CNT:");			//2行1列显示字符串CNT:
	
	while (1)
	{
		OLED_ShowNum(1, 5, Num, 5);			//不断刷新显示Num变量
		OLED_ShowNum(2, 5, Timer_GetCounter(), 5);		//不断刷新显示CNT的值
	}
}

/**
  * 函    数：TIM2中断函数
  * 参    数：无
  * 返 回 值：无
  * 注意事项：此函数为中断函数，无需调用，中断触发后自动执行
  *           函数名为预留的指定名称，可以从启动文件复制
  *           请确保函数名正确，不能有任何差异，否则中断函数将不能进入
  */
void TIM2_IRQHandler(void)
{
	if (TIM_GetITStatus(TIM2, TIM_IT_Update) == SET)		//判断是否是TIM2的更新事件触发的中断
	{
		Num ++;												//Num变量自增，用于测试定时中断
		TIM_ClearITPendingBit(TIM2, TIM_IT_Update);			//清除TIM2更新事件的中断标志位
															//中断标志位必须清除
															//否则中断将连续不断地触发，导致主程序卡死
	}
}

```

编译，下载。

此处我的红外传感器坏了TAT，手动断开针脚（手搓方波），计数器也在跳，姑且算是成功了吧。