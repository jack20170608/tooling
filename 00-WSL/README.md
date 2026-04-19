# WSL 常用命令

## 常用操作命令
```shell
## 查看安装的子系统
$ wsl -l -v
  NAME            STATE           VERSION
* Ubuntu-24.04    Stopped         2

## 连接对应的子系统
$ wsl -d Ubuntu-24.04
Welcome to Ubuntu 24.04 (GNU/Linux 5.15.90-microsoft-standard

## 备份
$ wsl --export Ubuntu-24.04 /G/wsl-backup/ubuntu2404.vhdx --vhd

## 恢复
$ wsl --import Ubuntu-24.04-docker /E/WSL/Ubuntu-24.04-docker /G/wsl-backup/ubuntu2404.vhdx --vhd

## 再次查看
$ wsl -l -v
  NAME                   STATE           VERSION
* Ubuntu-24.04           Stopped         2
  Ubuntu-24.04-docker    Stopped         2
## 注销
$ wsl --unregister Ubuntu-24.04-docker

## 再次查看
$ wsl -l -v
NAME            STATE           VERSION
* Ubuntu-24.04    Stopped         2

## shutdown wsl 
$ wsl --shutdown

```

## windows WSL的配置文件
```shell
## 这个文件在用户目录下，文件名为 .wslconfig, 这里用来配置wsl网络，防火墙，自动代理等功能
$ cat ~/.wslconfig
[wsl2]
networkingMode=mirrored
dnsTunneling=true
firewall=true
autoProxy=true

```

## WSL 子系统配置
```shell
## 这个文件在子系统的 /etc/wsl.conf, 这里用来配置子系统的默认用户，是否将windows路径添加到子系统的PATH环境变量中等功能
(base) jack@DESKTOP-NGVF990:/mnt/d/project$ cat /etc/wsl.conf
[interop]
appendWindowsPath=false

[user]
default=jack
```
