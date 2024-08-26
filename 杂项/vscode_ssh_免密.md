## vscode免密登录

### windows：创建公钥

```shell
ssh-keygen -t rsa
```

进入`C:\Users\username\.ssh\`

打开`id_rsa.pub`

复制内容

### linux：导入公钥

终端输入

```sh
 echo "xxxx" >> ~/.ssh/authorized_keys
```

即可添加