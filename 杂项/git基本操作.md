# Git的基本操作

## 将一个项目文件夹托管至代码托管平台

### step1 创建新仓库

在托管平台上创建一个新的仓库，例如github。

![image-20240826152513574](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240826152513574.png)

### step2 初始化仓库

在目标文件夹打开终端，输入

```shell
git init
```

文件夹会出现一个名为`.git`的隐藏文件夹：

![image-20240826152654934](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240826152654934.png)

### step3 添加文件到暂存区

```shell
git add .
```

### step4 设定注释信息

```shell
git commit -m "example info"
```

### step5 设置个人信息

```shell
git config --global user.email "youremail@example.com"
git config --global user.name "Your Name"
```

**设定公钥**

```shell
ssh-keygen -t rsa -C "youremail@example.com"
```

执行后生成相应的公钥，并存储至`Users/XXX/.ssh/id_rsa.pub`文件中

打开github设置，添加SSH keys

![image-20240826153944883](https://picgo-1301260628.cos.ap-guangzhou.myqcloud.com/image-20240826153944883.png)

### step6 绑定远程仓库

```shell
git remote add origin https://github.com/username/reponame.git
git push -u origin main  # 或者 master，取决于你的分支名称
```

### step7 push至远程仓库

``` shell
git push -u origin main
```

## 一键同步脚本

编写`auto-sync.bat`

```shell
@echo off
REM Navigate to the directory where the script is located
cd /d "%~dp0"

REM Pull the latest changes from the remote repository
echo Pulling latest changes from remote...
git pull origin main

REM Add any new or modified files to the staging area
echo Adding changes to staging area...
git add .

REM Commit changes with a default message
echo Committing changes...
git commit -m "Auto-sync changes"

REM Push the changes to the remote repository
echo Pushing changes to remote repository...
git push origin main

REM Pause to see the output
echo Sync complete!
pause

```

双击即可同步。

### 附加

另外，在另一个设备的时候可以执行

```shell
git clone [ssh]
```

将仓库拉取至本地。