# Rocky Linux 10 安装常用工具

## 简单的安装脚本
```shell
[root@dns10 yum.repos.d]# dnf install -y vim-enhanced \
&& dnf install -y git \
&& dnf install -y wget curl net-tools bind-utils \
&& dnf install -y tree tar htop
```

- [vim安装详细介绍](./vim)
- [git安装详细介绍](./git)
- [network相关工具](./network-related)
- [tree](./tree)
- [htop](./htop)
- [tar](./tar)
