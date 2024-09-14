# ADC数模转换器

## 简介

- ADC（Analoog-Digital Converter）模拟-数字转换器
- ADC可以将引脚上连续变化的模拟电压转换为内存中存储的数字变量，建立模拟电路到数字电路的桥梁
- 12位（分辨率：0~4095）逐次逼近型ADC，1us转换时间（1MHz）
- 输入电压范围：0~3.3V，转换结果范围：0~4095
- 18个输入通道，可测量16个外部和2个内部信号源（内部温度传感器、内部参考电压）
- 规则组（常规使用）和注入组（用于突发事件）两个转换单元
- 模拟看门狗自动检测输入电压范围
- STM32F103C8T6 ADC资源：ADC1、ADC2，10个外部输入通道

![image-20240903163928652](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240903163928652.png)

> 逐次逼近型ADC内部结构 （ADC0809）

![image-20240903164817177](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240903164817177.png)

> STM32 ADC框图 

![image-20240903165641857](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240903165641857.png)

> ADC基本结构图简化

![image-20240903170053776](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240903170053776.png)

> 输入通道 本次使用的芯片没有PCX引脚和ADC3



**转换模式**：

- 单次转换 非扫描模式
- 连续转换 非扫描模式
- 单次转换 扫描模式
- 连续转换 扫描模式

> 连续：转换一次不会停止
>
> 扫描：输出多个通道

![image-20240903170645785](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240903170645785.png)

> 触发控制



**数据对齐**：

![image-20240903170825231](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240903170825231.png)

> 由于此芯片ADC为12位，寄存器为16位，就需要考虑数据对齐。（左 右）



**转换时间：**

- AD转换的步骤：采样，保持，量化，编码
- STM32 ADC的总转换时间为：T = 采样时间 + 12.5个ADC周期
- 例如：当ADCCLK = 14MHz，采样时间为1.5个ADC周期 T = 1.5 + 12.5 = 14个ADC周期 = 1us



**校准：**

- ADC有一个内置自校准模式。校准可大幅减小因内部电容组的变化而造成的准精度误差。校准期间，在每个电容器上都会计算出一个误差修正码（数字值），这个码用于消除在随后的转换中每个电容器上产生的误差
- 建议在每次上电后执行一次校准
- 启动校准前，ADc必须处于关电状态超过至少两个ADC时钟周期。

## 项目实现

### AD单通道

#### 接线图

![image-20240904221021353](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240904221021353.png)

**再次查看结构框图：**

![image-20240904221703419](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240904221703419.png)

1. 开启ADC和GPIO的时钟，配置ADCCLK的分频器
2. 配置GPIO，把需要用的GPIO配置成模拟输入模式
3. 配置多路开关，把左边的通道接入右边的规则组列表里
4. 配置ADC转换器（使用结构体）
5. 开关控制，调用ADC_Cmd函数，开启ADC
6. 进行校准

#### 编辑`AD.c`

```c
#include "stm32f10x.h"                  // Device header

/**
  * 函    数：AD初始化
  * 参    数：无
  * 返 回 值：无
  */
void AD_Init(void)
{
	/*开启时钟*/
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_ADC1, ENABLE);	//开启ADC1的时钟
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);	//开启GPIOA的时钟
	
	/*设置ADC时钟*/
	RCC_ADCCLKConfig(RCC_PCLK2_Div6);						//选择时钟6分频，ADCCLK = 72MHz / 6 = 12MHz
	
	/*GPIO初始化*/
	GPIO_InitTypeDef GPIO_InitStructure;
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_AIN;
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_0;
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;
	GPIO_Init(GPIOA, &GPIO_InitStructure);					//将PA0引脚初始化为模拟输入
	
	/*规则组通道配置*/
	ADC_RegularChannelConfig(ADC1, ADC_Channel_0, 1, ADC_SampleTime_55Cycles5);		//规则组序列1的位置，配置为通道0
	
	/*ADC初始化*/
	ADC_InitTypeDef ADC_InitStructure;						//定义结构体变量
	ADC_InitStructure.ADC_Mode = ADC_Mode_Independent;		//模式，选择独立模式，即单独使用ADC1
	ADC_InitStructure.ADC_DataAlign = ADC_DataAlign_Right;	//数据对齐，选择右对齐
	ADC_InitStructure.ADC_ExternalTrigConv = ADC_ExternalTrigConv_None;	//外部触发，使用软件触发，不需要外部触发
	ADC_InitStructure.ADC_ContinuousConvMode = DISABLE;		//连续转换，失能，每转换一次规则组序列后停止
	ADC_InitStructure.ADC_ScanConvMode = DISABLE;			//扫描模式，失能，只转换规则组的序列1这一个位置
	ADC_InitStructure.ADC_NbrOfChannel = 1;					//通道数，为1，仅在扫描模式下，才需要指定大于1的数，在非扫描模式下，只能是1
	ADC_Init(ADC1, &ADC_InitStructure);						//将结构体变量交给ADC_Init，配置ADC1
	
	/*ADC使能*/
	ADC_Cmd(ADC1, ENABLE);									//使能ADC1，ADC开始运行
	
	/*ADC校准*/
	ADC_ResetCalibration(ADC1);								//固定流程，内部有电路会自动执行校准
	while (ADC_GetResetCalibrationStatus(ADC1) == SET);
	ADC_StartCalibration(ADC1);
	while (ADC_GetCalibrationStatus(ADC1) == SET);
}

/**
  * 函    数：获取AD转换的值
  * 参    数：无
  * 返 回 值：AD转换的值，范围：0~4095
  */
uint16_t AD_GetValue(void)
{
	ADC_SoftwareStartConvCmd(ADC1, ENABLE);					//软件触发AD转换一次
	while (ADC_GetFlagStatus(ADC1, ADC_FLAG_EOC) == RESET);	//等待EOC标志位，即等待AD转换结束
	return ADC_GetConversionValue(ADC1);					//读数据寄存器，得到AD转换的结果
}

```

#### 编辑`AD.h`

```c
#ifndef __AD_H
#define __AD_H

void AD_Init(void);
uint16_t AD_GetValue(void);

#endif

```

#### 编辑`main.c`

```c
#include "stm32f10x.h"                  // Device header
#include "Delay.h"
#include "OLED.h"
#include "AD.h"

uint16_t ADValue;			//定义AD值变量
float Voltage;				//定义电压变量

int main(void)
{
	/*模块初始化*/
	OLED_Init();			//OLED初始化
	AD_Init();				//AD初始化
	
	/*显示静态字符串*/
	OLED_ShowString(1, 1, "ADValue:");
	OLED_ShowString(2, 1, "Voltage:0.00V");
	
	while (1)
	{
		ADValue = AD_GetValue();					//获取AD转换的值
		Voltage = (float)ADValue / 4095 * 3.3;		//将AD值线性变换到0~3.3的范围，表示电压
		
		OLED_ShowNum(1, 9, ADValue, 4);				//显示AD值
		OLED_ShowNum(2, 9, Voltage, 1);				//显示电压值的整数部分
		OLED_ShowNum(2, 11, (uint16_t)(Voltage * 100) % 100, 2);	//显示电压值的小数部分
		
		Delay_ms(100);			//延时100ms，手动增加一些转换的间隔时间
	}
}

```



