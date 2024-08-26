# STM32的寄存器

## 什么是寄存器

​	寄存器是有限存储容量的高速存储部件，可以用来暂存指令、数据和地址。即寄存器是一个存储空间。

​	**某个寄存器的地址=基地址+偏移量**

## 寄存器的用处

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240807194958931.png" alt="image-20240807194958931" style="zoom:50%;" />

​	cpu有着许多引脚，绝大部分都是通用输出输入接口(GPIO)，每个引脚都有自己的名字，比如我们想要把GPIOB_PIN_0的模式设置为开漏输出模式。

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240807195203610.png" alt="image-20240807195203610" style="zoom:50%;" />

​	我们可以单独配置一个寄存器，去适配GPIOB这一组引脚。引脚的工作模式有许多种，我们可以分配4个bit去存储工作模式。

​	我们编程，就是为了改变寄存器的值，从而让引脚有着不同的输出输入，实现对硬件的控制。因此，**寄存器是程序和硬件沟通的桥梁**

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240807195513493.png" alt="image-20240807195513493" style="zoom:50%;" />

​	

## 寄存器的使用方法

​	以GPIO为例。参考官方手册，手册中并未指明所有寄存器的地址，需要稍加计算。



### 一、找到GPIOB的基地址

![BaseAddrOfGPIOB](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240807194136129.png)

如图，意思是GPIOB相关的寄存器，都在0x4001 0C00到0x4001 0FFF的范围内。

### 二、 找到端口输入寄存器地址的偏移

有了基地址，我们就需要进一步定位到准确的位置。

![](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240807194354051.png)

### 三、 找到存储数据的地方

比如PB3的数据，就位于从右往左数的第4个。

![image-20240807194546480](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240807194546480.png)

stm32的寄存器是32位，每个寄存器占据4字节，32位。