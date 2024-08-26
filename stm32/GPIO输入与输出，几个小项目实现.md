# GPIO输入与输出

## GPIO小知识

### GPIO的八种工作模式

1. **输入浮空（Floating Input）：**
   特点： 输入用，完全浮空，状态不定。
   应用： 适用于需要读取外部信号的场景，但外部信号状态不确定。

2. **输入上拉（Input Pull-Up）：**
   特点： 输入用，使用内部上拉电阻，初始状态是高电平。
   应用： 适用于外部信号默认为高电平的情况，如按钮按下时会拉低信号。

<!--more-->

3. **输入下拉（Input Pull-Down）：**
   特点： 输入用，使用内部下拉电阻，初始状态是低电平。
   应用： 适用于外部信号默认为低电平的情况，如按钮按下时会拉高信号。

4. **模拟功能（Analog Mode）：**
   特点： 用于连接模拟外设，如ADC（模数转换器）、DAC（数模转换器）等。
   应用： 适用于需要进行模拟信号处理的场景。

5.  **开漏输出（Open-Drain Output）：**
   特点： 用于实现开漏输出，常用于构建总线，如I2C。
   应用： 适用于需要多个输出端口共享同一信号线的场景，例如I2C的SDA、SCL线。

6. **推挽输出（Push-Pull Output）：**
   特点： 驱动能力强，支持通用输出，可提供较大电流。
   应用： 适用于需要输出到外部设备，需要较大驱动能力的场景。

7. **开漏式复用功能（Open-Drain Alternate Function）：**
   特点： 用于实现开漏输出，并复用了片上外设功能。
   应用： 适用于需要实现外设功能，同时共享信号线的场景，例如硬件I2C的SDA、SCL线。

8. **推挽式复用功能（Push-Pull Alternate Function）：**
   特点： 用于实现推挽输出，并复用了片上外设功能。
   应用： 适用于需要实现外设功能，同时需要提供较大驱动能力的场景，例如SPI的SCK、MISO、MOSI线。

> 以上内容转载自：[GPIO（简介、IO端口基本结构、GPIO的八种模式、GPIO寄存器、通用外设驱动模型、GPIO配置步骤、编程实战）-CSDN博客](https://blog.csdn.net/wdxabc1/article/details/139192494)

## 项目实现

### 按键控制LED

#### LED驱动程序

项目接线图如图所示：

![Wiring_diagram](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240808225033445.png)

创建Hardware文件夹，用于存放驱动文件，包括`.c`和`.h`文件。

![structure of project](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240808224422791.png)

添加`.c`和`.h`文件，命名为`LED.c`和`LED.h`。

![add_new_item_to_Hardware](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240808224457843.png)

编辑`LED.c`文件

```c
#include "stm32f10x.h"                  // Device header

void LED_Init(void)
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);
	
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_1 | GPIO_Pin_2;
    // 按位或可以同时选取两个引脚
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOA, &GPIO_InitStructure);
	
	GPIO_SetBits(GPIOA, GPIO_Pin_1 | GPIO_Pin_2);
}// 初始化时钟

void LED1_ON(void)
{
	GPIO_ResetBits(GPIOA, GPIO_Pin_1);
}// 低电平点亮

void LED1_OFF(void)
{
	GPIO_SetBits(GPIOA, GPIO_Pin_1);
}// 高电平熄灭

void LED1_Turn(void)
{
	if(GPIO_ReadOutputDataBit(GPIOA, GPIO_Pin_1) == 0)
	{
		GPIO_SetBits(GPIOA, GPIO_Pin_1);
	}
	else
	{
		GPIO_ResetBits(GPIOA, GPIO_Pin_1);
	}
}// 状态转换，低电平时切换为高电平，反之同理

// LED2的函数
void LED2_ON(void)
{
	GPIO_ResetBits(GPIOA, GPIO_Pin_2);
}

void LED2_OFF(void)
{
	GPIO_SetBits(GPIOA, GPIO_Pin_2);
}

void LED2_Turn(void)
{
	if(GPIO_ReadOutputDataBit(GPIOA, GPIO_Pin_2) == 0)
	{
		GPIO_SetBits(GPIOA, GPIO_Pin_2);
	}
	else
	{
		GPIO_ResetBits(GPIOA, GPIO_Pin_2);
	}
}

```

编辑`LED.h`文件，声明函数。

```c
#ifndef __LED_H // 宏定义保护，防止重复引用
#define __LED_H

void LED_Init(void);
void LED1_ON(void);
void LED1_OFF(void);
void LED1_Turn(void);
void LED2_ON(void);
void LED2_OFF(void);
void LED2_Turn(void);

#endif

```



#### Key驱动程序

我们需要获得按键所连引脚的状态，还需要对按键写一个驱动程序。

一下是获取引脚电平数值的函数：

```c
uint8_t GPIO_ReadInputDataBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin);
uint16_t GPIO_ReadInputData(GPIO_TypeDef* GPIOx);
uint8_t GPIO_ReadOutputDataBit(GPIO_TypeDef* GPIOx, uint16_t GPIO_Pin);
uint16_t GPIO_ReadOutputData(GPIO_TypeDef* GPIOx);
```

其中，`putData`是获得整个寄存器的数值，`putDataBit`是获得单个引脚的数值

> 注意：当按键按下时，由于按键的特性，会出现信号抖动的情况。如图：
>
> ![signal_bouncing](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240808225437769.png)
>
> 因此，我们需要在程序中添加延时函数，减小误差。

如上文，创建`.c`和`.h`文件，如图：

![file_name](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240808225221443.png)

编辑`key.c`文件

```c
#include "stm32f10x.h"                  // Device header
#include "Delay.h"

void Key_Init(void)
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);
	
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPU;
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_1 | GPIO_Pin_11;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOB, &GPIO_InitStructure);
}
// 初始化时钟

uint8_t Key_GetNum(void)
{
	uint8_t KeyNum = 0;
	if(GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_1) == 0)
    // 读取键码的返回值，并且判断
	{
		Delay_ms(20);// 延时，消除按键抖动
		while(GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_1) == 0);
        // 当按键未弹起时，不进行下一步操作
		Delay_ms(20);
		KeyNum = 1;
	}
	if(GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_11) == 0)
	{
		Delay_ms(20);
		while(GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_11) == 0);
		Delay_ms(20);
		KeyNum = 2;
	}
	return KeyNum;
}

```

编辑`key.h`文件

```c
#ifndef __KEY_H
#define __KEY_H

void Key_Init(void);
uint8_t Key_GetNum(void);

#endif

```

至此，按键和LED的驱动程序就完成了，接下来只需要理顺代码逻辑即可。

#### 编辑main.c文件

```c
#include "stm32f10x.h"                  // Device header
#include "Delay.h"
#include "LED.h"
#include "Key.h"

uint8_t KeyNum;		//定义用于接收按键键码的变量

int main(void)
{
	/*模块初始化*/
	LED_Init();		//LED初始化
	Key_Init();		//按键初始化
	
	while (1)
	{
		KeyNum = Key_GetNum();		//获取按键键码
		
		if (KeyNum == 1)			//按键1按下
		{
			LED1_Turn();			//LED1翻转
		}
		
		if (KeyNum == 2)			//按键2按下
		{
			LED2_Turn();			//LED2翻转
		}
	}
}

```

编译，下载即可实现效果。

### 光敏电阻控制蜂鸣器

#### 接线图

如图所示：

![wiring_diagram](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240808230819175.png)

#### 光敏电阻驱动

> 此处光明电阻模块默认输出低电平。当光线不足时，输出高电平。

如上文，创建驱动文件至Hardware文件夹:

![struc_of_Hardware](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240808230559910.png)

编辑`.c`文件

```c
#include "stm32f10x.h"                  // Device header

void LightSensor_Init(void)
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);
	
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IPU;
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_13;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOB, &GPIO_InitStructure);
}
// 模块初始化

uint8_t LightSensor_Get(void)
{
	return GPIO_ReadInputDataBit(GPIOB, GPIO_Pin_13);
    // 直接返回数值，当光线不足，输出高电平，值为1
}

```

编辑`.h`文件

```c
#ifndef __LIGHT_SENSOR_H
#define __LIGHT_SENSOR_H

void LightSensor_Init(void);
uint8_t LightSensor_Get(void);

#endif

```

#### 蜂鸣器驱动

编辑`.c`文件

```c
#include "stm32f10x.h"                  // Device header

void Buzzer_Init(void)
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);
	
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_Out_PP;
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_12;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOB, &GPIO_InitStructure);
	
	GPIO_SetBits(GPIOB, GPIO_Pin_12);
}

void Buzzer_ON(void)
{
	GPIO_ResetBits(GPIOB, GPIO_Pin_12);
}

void Buzzer_OFF(void)
{
	GPIO_SetBits(GPIOB, GPIO_Pin_12);
}

void Buzzer_Turn(void)
{
	if(GPIO_ReadOutputDataBit(GPIOA, GPIO_Pin_12) == 0)
	{
		GPIO_SetBits(GPIOB, GPIO_Pin_12);
	}
	else
	{
		GPIO_ResetBits(GPIOB, GPIO_Pin_12);
	}
}

```

编辑`.h`文件

```c
#ifndef __BUZZER_H
#define __BUZZER_H

void Buzzer_Init(void);
void Buzzer_ON(void);
void Buzzer_OFF(void);
void Buzzer_Turn(void);

#endif

```

至此，各模块驱动程序已完成。

#### 编辑main.c文件

```c
#include "stm32f10x.h"                  // Device header
#include "Delay.h"
#include "Buzzer.h"
#include "LightSensor.h"

int main(void)
{
	/*模块初始化*/
	Buzzer_Init();			//蜂鸣器初始化
	LightSensor_Init();		//光敏传感器初始化
	
	while (1)
	{
		if (LightSensor_Get() == 1)		//如果当前光敏输出1
		{
			Buzzer_ON();				//蜂鸣器开启
		}
		else							//否则
		{
			Buzzer_OFF();				//蜂鸣器关闭
		}
	}
}

```

编译，下载即可实现效果。

