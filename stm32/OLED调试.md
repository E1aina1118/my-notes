# OLED调试与Keil调试

## 调试方法

- **串口调试**：通过串口通信，将调试信息发送到电脑端，电脑使用串口助手显示调试信息
- **显示屏调试**：直接将显示屏连接到单片机，将调试信息打印在显示屏上
- **Keil调试模式**：借助Keil团建的调试模式，可使用单步运行、设置断点、查看寄存器及变量等功能

<!--more-->

> 目前阶段只需要对几个参数的值进行查看，选择OLED显示屏调试会更方便。

## OLED调试

### OLED简介

OLED(Organic Light Emitting Diode)：有机发光二极管

OLED显示屏具有功耗低、响应速度快、宽视角、轻薄柔韧等特点

0.96寸OLED模块：是电子设计中非常常见的显示屏模块

供电：3~5.5V，通信协议：I2C/SPI，分辨率：128*64

![image-20240809171527423](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809171527423.png)

![image-20240809171620777](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809171620777.png)

![image-20240809171819395](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809171819395.png)

![image-20240809171836568](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809171836568.png)

### 使用OLED显示屏

#### 接线图

![image-20240809172115203](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809172115203.png)

#### 添加驱动文件

![image-20240809173658022](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809173658022.png)

打开`OLED.h`，可以看到可调用的函数：

```c
#ifndef __OLED_H
#define __OLED_H

void OLED_Init(void);
void OLED_Clear(void);
void OLED_ShowChar(uint8_t Line, uint8_t Column, char Char);
void OLED_ShowString(uint8_t Line, uint8_t Column, char *String);
void OLED_ShowNum(uint8_t Line, uint8_t Column, uint32_t Number, uint8_t Length);
void OLED_ShowSignedNum(uint8_t Line, uint8_t Column, int32_t Number, uint8_t Length);
void OLED_ShowHexNum(uint8_t Line, uint8_t Column, uint32_t Number, uint8_t Length);
void OLED_ShowBinNum(uint8_t Line, uint8_t Column, uint32_t Number, uint8_t Length);

#endif

```

#### 测试驱动文件

```c
#include "stm32f10x.h"                  // Device header
#include "delay.h"
#include "OLED.h"

int main(void)
{
	OLED_Init();// 初始化OLED
	
	OLED_ShowChar(1,1,'A');// 显示单个字符
	OLED_ShowString(1,3,"HelloWorld!");// 显示字符串
	while(1)
	{

	}
}

```

效果：

![effect](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809174711401.png)

#### 使用OLED函数

其余函数用法：

```c
#include "stm32f10x.h"                  // Device header
#include "delay.h"
#include "OLED.h"

int main(void)
{
	OLED_Init();
	
	OLED_ShowChar(1,1,'A');
	OLED_ShowString(1,3,"HelloWorld!");
	OLED_ShowNum(2,1,12345,5);
	OLED_ShowSignedNum(2,7,-66,2);
	OLED_ShowHexNum(3,1,0xAA55,4);
	OLED_ShowBinNum(4,1,0xAA55,16);
	
	while(1)
	{

	}
}

```

效果：

![effect](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809175921223.png)

> 手机拍摄效果与实际有差异。

## 使用Keil调试

以**3-1 LED闪烁**项目为例子。

![](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809180236341.png)

启用`Use Simulator`选项。

![image-20240809181405268](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809181405268.png)

点击红色d的按钮，进入调试模式。

![image-20240809181431212](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809181431212.png)

调试界面：

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240809181552304.png" alt="image-20240809181552304" style="zoom: 50%;" />