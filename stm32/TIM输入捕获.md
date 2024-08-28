# TIM输入捕获

## 简介

- IC(Input Capture) 输入捕获
- 输入捕获模式下，当通道输入引脚出现指定电平跳变时，当前CNT的值将被存到CCR中，可用于测量PWM波形的频率、占空比、脉冲间隔、电平持续时间等参数。
- 每个高级定时器和通用定时器都拥有4个输入捕获通道
- 可配置为PWMI模式，同时测量频率和占空比
- 可配合主从触发模式，实现硬件全自动测量

## 频率测量

![image-20240827150037917](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240827150037917.png)

- **测频法**要求信号频率高一些，实际上测量的时闸门时间内的平均频率，有一定的滤波作用，值比较平滑，结果更新慢
- **测周法**要求信号频率低一些，结果更新快，受噪声影响大，有波动

- **中界频率**，将以上两种方法的N提出来，使其相等，得到公式。因为以上两种方法均有结尾计次不完整的误差。

当待测信号频率小于中界频率的时候，**测周法**误差更小，当待测频率大于中界频率的时候，**测频法**误差更小。



## 项目实现

### 输入捕获模式测频率

#### 结构图

![image-20240828134301971](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240828134301971.png)

![image-20240828134605114](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240828134605114.png)

![image-20240828134523625](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240828134523625.png)

![image-20240828135628313](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240828135628313.png)

- 可以用于测量频率。

- 通过输入捕获通道1的GPIO口，输入一个方波信号（左上图），经过滤波器和边缘检测，选择TI1FP1为上升沿触发，输入选择直连的通道，分频器选择不分频。

- 当TI1FP1出现上升沿之后，CNT的当前计数值转运到CCR1里。同时触发源选择，选中TI1FP1为触发信号，从模式选择复位操作（Reset）。这样，TI1FP1的上升沿也会通过上面（出发沿选择）这条路，去触发CNT清零。

- 先后顺序：先转运CNT计数器的值至CCR1中，再触发从模式给CNT清零

> **注意事项**：ARR自动重装器的最大值为65535，CNT的最大也只能计65535个数。如果待测信号频率过低，**可能会导致CNT计数器溢出**。

#### 接线图

![image-20240828140707691](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240828140707691.png)

1. RCC开启时钟，把GPIO和TIM的时钟打开。
2. GPIO初始化，把GPIO配置为输入模式，一般为上拉输入或浮空输入。
3. 配置时基单元，让CNT计数器在内部时钟的驱动下自增运行。
4. 配置输入捕获单元，包括滤波器、极性、直连通道还是交叉通道、分频器等参数。（使用一个结构体即可统一进行配置）

5. 选择从模式的触发源，触发源选择TI1FP1。（调用库函数，给一个参数就好了）
6. 选择触发之后执行的操作，执行Reset。
7. 这些所有电路配置好之后，调用TIM_Cmd函数，开启定时器。

> 通过查看库函数，有**TIM_SetCompare**函数与**TIM_GetCapture**函数两两对应。在**输出比较模式**下，CCR是只写的，在**输入捕获的模式**下，CCR是只读的。



#### 编辑`IC.c`

```c
#include "stm32f10x.h"                  // Device header

/**
  * 函    数：输入捕获初始化
  * 参    数：无
  * 返 回 值：无
  */
void IC_Init(void)
{
	/*开启时钟*/
	RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM3, ENABLE);			//开启TIM3的时钟
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);			//开启GPIOA的时钟
	
	/*GPIO初始化*/
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPU;
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_6;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOA, &GPIO_InitStructure);							//将PA6引脚初始化为上拉输入
	
	/*配置时钟源*/
	TIM_InternalClockConfig(TIM3);		//选择TIM3为内部时钟，若不调用此函数，TIM默认也为内部时钟
	
	/*时基单元初始化*/
	TIM_TimeBaseInitTypeDef TIM_TimeBaseInitStructure;				//定义结构体变量
	TIM_TimeBaseInitStructure.TIM_ClockDivision = TIM_CKD_DIV1;     //时钟分频，选择不分频，此参数用于配置滤波器时钟，不影响时基单元功能
	TIM_TimeBaseInitStructure.TIM_CounterMode = TIM_CounterMode_Up; //计数器模式，选择向上计数
	TIM_TimeBaseInitStructure.TIM_Period = 65536 - 1;               //计数周期，即ARR的值
	TIM_TimeBaseInitStructure.TIM_Prescaler = 36 - 1;               //预分频器，即PSC的值
    // TIM_TimeBaseInitStructure.TIM_Prescaler = 72 - 1;
	TIM_TimeBaseInitStructure.TIM_RepetitionCounter = 0;            //重复计数器，高级定时器才会用到
	TIM_TimeBaseInit(TIM3, &TIM_TimeBaseInitStructure);             //将结构体变量交给TIM_TimeBaseInit，配置TIM3的时基单元
	
	/*输入捕获初始化*/
	TIM_ICInitTypeDef TIM_ICInitStructure;							//定义结构体变量
	TIM_ICInitStructure.TIM_Channel = TIM_Channel_1;				//选择配置定时器通道1
	TIM_ICInitStructure.TIM_ICFilter = 0xF;							//输入滤波器参数，可以过滤信号抖动
	TIM_ICInitStructure.TIM_ICPolarity = TIM_ICPolarity_Rising;		//极性，选择为上升沿触发捕获
	TIM_ICInitStructure.TIM_ICPrescaler = TIM_ICPSC_DIV1;			//捕获预分频，选择不分频，每次信号都触发捕获
	TIM_ICInitStructure.TIM_ICSelection = TIM_ICSelection_DirectTI;	//输入信号交叉，选择直通，不交叉
	TIM_ICInit(TIM3, &TIM_ICInitStructure);							//将结构体变量交给TIM_ICInit，配置TIM3的输入捕获通道
	
	/*选择触发源及从模式*/
	TIM_SelectInputTrigger(TIM3, TIM_TS_TI1FP1);					//触发源选择TI1FP1
	TIM_SelectSlaveMode(TIM3, TIM_SlaveMode_Reset);					//从模式选择复位
																	//即TI1产生上升沿时，会触发CNT归零
	
	/*TIM使能*/
	TIM_Cmd(TIM3, ENABLE);			//使能TIM3，定时器开始运行
}

/**
  * 函    数：获取输入捕获的频率
  * 参    数：无
  * 返 回 值：捕获得到的频率
  */
uint32_t IC_GetFreq(void)
{
	// return 1000000 / TIM_GetCapture1(TIM3);		//测周法得到频率fx = fc / N
    return 2000000 / TIM_GetCapture1(TIM3);
}

```

#### 编辑`IC.h`

```c
#ifndef __IC_H
#define __IC_H

void IC_Init(void);
uint32_t IC_GetFreq(void);

#endif

```

#### 编辑`main.c`

```c
#include "stm32f10x.h"                  // Device header
#include "Delay.h"
#include "OLED.h"
#include "PWM.h"
#include "IC.h"

int main(void)
{
	/*模块初始化*/
	OLED_Init();		//OLED初始化
	PWM_Init();			//PWM初始化
	IC_Init();			//输入捕获初始化
	
	/*显示静态字符串*/
	OLED_ShowString(1, 1, "Freq:00000Hz");		//1行1列显示字符串Freq:00000Hz
	
	/*使用PWM模块提供输入捕获的测试信号*/
	PWM_SetPrescaler(720 - 1);					//PWM频率Freq = 72M / (PSC + 1) / 100
	PWM_SetCompare1(50);						//PWM占空比Duty = CCR / 100
	
	while (1)
	{
		OLED_ShowNum(1, 6, IC_GetFreq(), 5);	//不断刷新显示输入捕获测得的频率
	}
}

```

> 此时，显示为**1001Hz**，始终有1Hz的误差，可能是由于电路结构等问题造成的。此时，可以通过将**输入捕获**定时器的预分频器的 **72-1** 改成 **36-1**， 再将**IC_GetFreq**函数中改为**`return 2000000 / TIM_GetCapture1(TIM3);`**



### PWMI模式测频率占空比

#### 结构图

![image-20240828135803782](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240828135803782.png)

这个PWMI模式，使用了两个通道同时捕获一个引脚，可以同时测量频率和占空比。

其中，上面一个通道与上一个项目相同，可以测量频率。再添加一路TI1FP2，配置为下降沿触发，通过交叉通道，去触发通道2的捕获单元。

**在下降沿的时刻，触发CCR2捕获，这是CCR2的值，就是高电平存在的计数值，CCR2的捕获，并不会触发CNT清零。由此可得，CCR1是一整个周期的计数值，CCR2就是高电平期间的计数值。我们用CCR2/CCR1，就是占空比了。**

> 当然也可以配置两个通道捕获第二个引脚的输入，这样就是使用**TI2FP1和TI2FP2**两个引脚了。

对比上一个项目，我们需要将捕获初始化的部分**进行升级**，配置成**两个通道同时捕获同一个引脚**的模式。
