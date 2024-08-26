## 前言

​	因为在学习ROS，在台式电脑上安装了ubuntu20.04。最近往返实验室，发现笔记本电脑没有ubuntu系统的话还是不太方便。宿舍的台式机是用的双系统，每次启动的时候可以选择要进入的系统。但是笔记本电脑的话，为了不想破坏笔记本电脑原生生态，就选择了使用虚拟机，相对来说对windows原本的系统破坏不是特别大。

## 准备材料

<!--more-->

**Ubuntu20.04镜像文件**

VM安装包网上自搜，官网访问速度慢且麻烦（好像还要注册什么东西）。这里有个网盘链接可供选择：https://pan.baidu.com/s/1WQ7V0nawt65-wTNIVn2ezg?from=init&pwd=bj99

**VMware Workstation 17。**

Ububntu20.04系统镜像在可以在清华镜像站获取：[Index of /ubuntu-releases/20.04/ | 清华大学开源软件镜像站 | Tsinghua Open Source Mirror](https://mirrors.tuna.tsinghua.edu.cn/ubuntu-releases/20.04/)

## 开始安装

1. **安装VMware**

按照引导安装即可。

安装完成界面：

![vm界面](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240710175116529.png)

2. **创建虚拟机**

按照图示设置，图示无说明保持默认设置：

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240710175226593.png" alt="image-20240710175226593" style="zoom: 67%;" />

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240710175337536.png" alt="image-20240710175337536" style="zoom:67%;" />

注意要选择**Ubuntu 64位**

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240710175418480.png" alt="image-20240710175418480" style="zoom:67%;" />

内存大小按照自己的需求来定。

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240710175729822.png" alt="image-20240710175729822" style="zoom:67%;" />

选择**”将虚拟磁盘拆分成多个文件“**，可以节约原本系统的空间（**用多少占多少**），**”立即分配所有磁盘空间“**，将会**一次性**将硬盘占用50GB

<img src="https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240710175857501.png" alt="image-20240710175857501" style="zoom:67%;" />

![image-20240710180007583](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240710180007583.png)

![image-20240710180038808](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240710180038808.png)

**启动虚拟机。**

![image-20240710180152068](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240710180152068.png)

3. **安装Ubuntu20.04系统**

系统语言，键盘布局都选择**简体中文**。

软件更新取消勾选。

![image-20240710183047615](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240710183047615.png)

其余选项默认。

**用户名设置：**

![image-20240710182836857](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240710182836857.png)

**等待安装完成：**

![image-20240710182921931](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240710182921931.png)

## 补充：ROS的一键安装

打开终端：

运行 **鱼香ROS**一键安装程序。

`wget http://fishros.com/install -O fishros && bash fishros`

根据程序引导进行安装。



​	

​	