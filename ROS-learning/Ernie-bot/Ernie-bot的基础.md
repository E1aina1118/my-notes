# 文心模型Ernie-bot的基础
## 安装
官方参考：[安装和鉴权 - ERNIE Bot Agent (ernie-bot-agent.readthedocs.io)](https://ernie-bot-agent.readthedocs.io/zh-cn/latest/quickstart/preparation/)
- 源码安装
进入项目文件夹
`git clone https://github.com/PaddlePaddle/ERNIE-SDK.git`
进入sdk文件夹
`cd ERNIE-SDK`
安装Ernie Bot
`pip install ./erniebot`
安装ERNIE Bot Agent
`pip install ./erniebot-agent`
- 添加token
在AI studio获取个人Token
然后在文件中加入
```python
import erniebot

erniebot.api_type = "aistudio"
erniebot.access_token = "Your Token"
```
- 快速开始
```python
# -*- coding: UTF-8 -*-
import erniebot

erniebot.api_type = "aistudio"
erniebot.access_token = "Your Token"

response = erniebot.ChatCompletion.create(
model='ernie-bot',
messages=[{'role': 'user', 'content': "hello world"}],
)

print(response.get_result())
```
- 效果展示

![输入图片说明](/imgs/2024-05-21/2d4fls95zShMN4Ll.png)
## 与OCR文字识别的结合
<!--stackedit_data:
eyJoaXN0b3J5IjpbLTY3MDAwOTkyOV19
-->