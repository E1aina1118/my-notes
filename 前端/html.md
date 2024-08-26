# The Basic Language of the Web : HTML

## 简介

> 莫名奇妙想学一点前端，毕竟用typecho，wordpress之类的框架，对于网页的结构还是过于模糊，因此入门一下前端知识，做出自己想要的效果。

这里观看的教程是: https://www.bilibili.com/video/BV1A34y1e7wL

是一个优质的国外的教程，配有中文字幕，感觉质量还是蛮高的，讲的很详细，真手把手教。下面就简单记一点笔记吧，感觉最近学的太杂怕全忘了白学。

## HTML Document Structure

### 概述

> html不算是一种编程语言，是一种标记语言。

一个**.html**文件，具有一定的结构，基本结构：

```html
<!DOCTYPE html> //声明文件类型，让浏览器以html去渲染代码
<html>
  <head> //可以定义这个html的一些性质，比如title
      ...
  </head>

  <body> // 主体部分，内容往里加
      ...
  </body>
</html>

```

使用**Vscode**，输入感叹号加上**tab**，可以快速生成基本框架，如下：

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    
</body>
</html>
```

### 代码实现

**HTML**版的**Hello, world!**

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My first webpage</title>
  </head>
  <body>
    <h1>Hello, world!</h1>
    <p>My name is Elaina, and this is my very first webpage :D</p>
  </body>
</html>

```

这里使用Vscode的模板，定义了title为“My first webpage"，定义了一个标题和一个段落。

### 效果展示

保存示例代码，双击使用浏览器就可以打开。

![hello world](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240731182010359.png)

## Text Elements

### 种类

#### heading

```html
<h1></h1>
<h2></h2>
<h3></h3>
...
<h6></h6>
```

效果：

![effects of heading](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240731182503190.png)

#### Paragraph

```html
<p></p>
```

效果：

![effects of paragraph](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240731183023018.png)

> Tips：注释方法：
>
> ```html
> <!-- -->
> ```

#### Bold & Strong

```html
<b></b>
<strong></strong>
```

加粗，后者有**强调**的语义

#### italic && emphasis

```html
<i></i>
```

斜体，但是并不带有任何特定的语义重要性。

```html
<em></em>
```

同样是斜体，代表强调，向浏览器和搜索引擎提供了关于本文重要性的语义信息。

即italic仅仅只是斜体样式，但是emphasis不仅是斜体，还带有强调的意思。

#### ordered list

```html
<ol>
    <li></li>  // list
    ...
    <li></li>
</ol>
```

有序列表

效果：

![effect ogf ordered list](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240802175019190.png)

#### unordered list

```html
<ul>
    <li></li>
    ...
    <li></li>
</ul>
```

无序列表

效果：

![effect of unordered list](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240802175247872.png)



#### Images and Attributes

> **属性**（Attributes）是HTML元素（标签）的**额外信息**，提供HTML元素的更多细节



```html
<img src="path to your source" alt="alternative descripition to your image" width="500" height="200"/>
```

这个标签`<img/>`的几个常见属性：

- src  图片源
- alt   替代描述
- width   图片宽度
- height   图片高度



> 关于alt参数，当图片无发加载时，浏览器依然可以显示`alt`的内容。同时，有助于搜索引擎了解图片的内容，也可便于障碍人士阅读。
>
> 当浏览器无法加载图片时，源码如果这样写：
>
> ![source code](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240802180803316.png)
>
> 显示效果为：
>
> ![effect of alt attribute](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240802180843133.png)



#### button

```html
<button>button</button>
```

按钮

效果：

![effect of button](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240802222308037.png)



#### Anchor (Hyperlinks)

```html
<a href="https://bing.com">Bing</a>
```

超文本引用`href`，全称**Hypertext Reference**，可以填入url地址，将文本指向链接。

效果：

![effect of anchor](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240802182309453.png)

可以嵌套使用：

![effect of anchor 2](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240802182331938.png)

此时单击文本，会在当前标签页直接变成目标网页。可以添加`target`属性，可以指定打开方式。

例如，我们想要从新的标签页中打开一个网页：

```html
<a href="https://bing.com" target="_blank">Bing</a>
```

**target**属性有四个参数：

- _self	在当前窗口打开（默认）

- _blank     在新的窗口或标签页打开

- _parent

   如果 `<a>` 标签位于 `<frame>` 或 `<iframe>` 元素内部，那么 `_parent` 会使链接在当前框架的父框架中打开。如果链接已经位于顶层框架中，那么其行为与 `_self` 相同。

- _top

  类似于 `_parent`，但如果 `<a>` 标签位于嵌套框架中，`_top` 会使链接在顶层框架中打开，即移除所有嵌套的框架并显示链接的内容。如果链接已经位于顶层框架中，那么其行为与 `_self` 相同。

> 入门阶段常用前两个

##### 实战：标签页的跳转

实现在当前标签页，通过`anchor`标签，跳转至另一个标签页

首先，创建一个简单的“博客”标签**blog.html**

```html
<!DOCTYPE html>
<html>
    <head>
        <title>Blog</title>
    </head>
    <body>
        <h2>BLOG</h2>
    </body>
</html>
```

在**index.html**添加一个超链接，指向新目标标签页

```html
<a href="blog.html">Blog</a>
```

效果：

![effect of anchor](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240802183735488.png)

![effect of anchor](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240802183755810.png)

此时，我们也可以在“博客”标签页，添加一个anchor，指向index标签页。

```html
<a href="index.html">Back to HOME</a>
```

效果：

![effect of back to home](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240802184008092.png)

> anchor标签的href属性如果没有参数，将不会指向任何地方。如果参数为`#`,即`<a href="#">test</a>`，单击该文本，会回到当前标签页的顶部。



## Structuring our Page

> 在构建网页的时候，元素过多时，常常导致结构混乱，难以维护加工（如CSS）。因此需要将我们的代码模块化，分为许多不同的区块，让结构更加地清晰。

```html
<header>
    <h1>The Title</h1>
	<nav>
        <a href="#">section1</a>
        <a href="#">section2</a>
        <a href="#">section3</a>
    </nav>
</header>
```

`header`是一个网页的顶部部分。`nav`是导航模块。他们都像是一个容器，将代码分类，装在一起。

将网页顶部元素嵌套进入`header`等标签中，在视觉呈现上并无差别，但更有益于模块化地对代码进行维护。（无形的盒子）

类似的标签有：

- header

```html
<header></header>
```

- article

```html
<article></article>
```

- nav

```html
<nav></nav>
```

- footer

```html
<footer>
    Copyright &copy; by Elaina1118
</footer>
```

- div

```html
<div></div>
```

更加通用，当我们不想给一个区块附有语义时，可以使用div(division)

- aside

```html
<aside></aside>
```

次要信息(比如相关网页)



#### 实战

##### 目标

实现如图所示的效果：

![target effect](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240802235819112.png)

##### 代码实现

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Converse Chuck Tatlor All Star Low Top</title>
  </head>
  <body>
    <div>
      <header>
        <h1>Converse Chuck Taylor All Star Low Top</h1>
      </header>
      <article>
        <img
          src="challenges.jpg"
          alt="picture of goods"
          width="300"
          height="300"
        />
        <p><b>$65.00</b></p>
        <p>Free shipping</p>
        <p>
          Ready to dress up or down, these classic canvas Chucks are an everyday
          wardrode staple.
        </p>
        <p>
          <a href="#"><u>More information &rarr;</u></a>
        </p>
      </article>
      <p><b>Produc details</b></p>
      <ul>
        <li>Lightweight, durable canvas sneaker</li>
        <li>Lightly padded footbed for added comfort</li>
        <li>Iconic Chuck Taylor ankle patch</li>
      </ul>
      <button>Add to cart</button>
    </div>
  </body>
</html>

```

##### 效果呈现

效果：

![effect](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240803000006261.png)



## Semantic HTML

> ​	前面的例子中，如italic和emphasis，bold和strong的区别。他们主要是**语义的区别**。当我们构建网页的时候，我们应该首先强调一些元素的意义、目的，而样式是其次的。**语义化HTML(Semantic HTML)**，是编写HTML的方式，用来增强网页内同的**结构**。这有助于网页内容对搜索引擎、使用辅助技术的用户更加友好。
