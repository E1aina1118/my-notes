# Opencv-python基础
## Opencv的简介
OpenCV是一个开源的计算机视觉库，提供了丰富的图像处理算法和功能。它支持多种编程语言，包括Python、C++、C#等。OpenCV的主要功能包括图像处理、图像识别、图像合成等。
## Opencv-python 的安装
为了更好地管理各项目之间的环境，这里使用anaconda进行安装
激活环境paddle_env（之前项目创建好的）
```activate paddle_env```

![输入图片说明](/imgs/2024-05-16/aGpx0kSUoXgk2OO6.png)

安装opencv-python库
```pip install opencv-python```

![输入图片说明](/imgs/2024-05-16/Qfu5Q3aEnAX3HfSr.png)

可见已经安装成功
## Opencv的基本操作
### 图像的显示与存储
```python
# -*-coding:utf-8 -*-

import cv2 #导入opencv库

image = cv2.imread('images/1.png')#读入一个图片

cv2.imshow('Image',image)#展示图片
cv2.waitKey(0)#等待用户输入，若还未输入，图片保持存在
cv2.destroyAllWindows()#关闭所有窗口

cv2.imwrite('./output/output.jpg',image)#输出图片于output文件夹
```
### 图像变换
```python
# -*-coding:utf-8 -*-
# 导入opencv库
import cv2

# 打开图像
image = cv2.imread('images/2.jpg')

# 缩放图像
scaled_image = cv2.resize(image,(50,50))

# 旋转图像（此处为顺时针旋转90度）
rotated_image = cv2.rotate(image,cv2.ROTATE_90_CLOCKWISE)

# 裁剪图像
cropped_image = image[100:300,100:300]

# 显示变换后的图像
cv2.imshow('Scaled Image', scaled_image)
cv2.imshow('Rotated Image', rotated_image)
cv2.imshow('Cropped Image', cropped_image)
cv2.waitKey(0)
cv2.destroyAllWindows()
```
测试图：

![输入图片说明](/imgs/2024-05-16/TZqWZZEVMn0fYblb.jpeg)

变换效果：

![效果图](/imgs/2024-05-16/rxLRYlPk7AXmZszd.png)

### 图像增强
```python
enhanced_image = cv2.convertScaleAbs(image,alpha=1.5,beta=0)
```
效果：

![输入图片说明](/imgs/2024-05-16/48pGqnBCnvfF3nAA.png)

我们使用OpenCV库的`cv2.convertScaleAbs()`函数来增强图像的对比度
### 图像复原
```python
denoised_image = cv2.fastNlMeansDenoisingColored(image,None,10,10,7,21)
```

![输入图片说明](/imgs/2024-05-16/jivFslpmbu9XYF8b.png)

使用OpenCV库的`cv2.fastNlMeansDenoisingColored()`函数来去除图像中的噪声

### 颜色分割
```python
lower = (100,50,50)
upper = (255,255,255)

mask = cv2.inRange(image,lower,upper)
```

![输入图片说明](/imgs/2024-05-16/xn9dlOOkGbUn6uv0.png)

`lowerb` 和 `upperb` 是简单的数值，用于定义要保留的像素值范围。在上面的例子中，`mask` 将是一个二值图像，其中在蓝色范围内的像素值为 255（白色），而其他像素值为 0（黑色）。

### 图像特征提取
```python
edges = cv2.Canny(image,100,200)
```

效果图：

![输入图片说明](/imgs/2024-05-16/9131UmERyZaft34o.png)


<!--stackedit_data:
eyJoaXN0b3J5IjpbLTIxMDg0MzAxMDUsMTQ4MDk0NTY1LC0xMT
YzMTU2NDA2LDExMzE0NjM0MTIsMTQ2Mjg4NTk1OSwtMTg1MzIx
OTk0LC0xNDk5MTYwNzUxLC0yMTQ2NzkzNzAwXX0=
-->