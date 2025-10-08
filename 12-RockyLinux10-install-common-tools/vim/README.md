# VIM 的安装和配置

## 使用系统自带包管理器（推荐）

### 安装 Vim

```shell
# 更新软件包索引
sudo dnf check-update

# 安装最小版Vim
sudo dnf install -y vim-minimal

# 或安装完整版Vim
sudo dnf install -y vim-enhanced
```

### 升级vim
```shell
# 升级所有系统软件包（包括Vim）
sudo dnf upgrade -y

# 或只升级Vim
sudo dnf upgrade -y vim-enhanced
```

### 验证安装
```shell
# 检查Vim版本
vim --version | head -n 1
```

## 一个推荐的配置文件
这里推荐一个简单的配置文件[.vimrc](.vimrc)，适用于大多数场景。

```shell
# 备份原始配置文件
cp ~/.vimrc ~/.vimrc.bak

# 复制配置文件到服务器
scp .vimrc jack@dns10.t:/home/jack/.vimrc
scp .vimrc root@dns10.t:/root/.vimrc

# 重启Vim
vim
```

更多安装和配置的方法可以参考链接。


## 参考资料
- [Vim 官方文档](https://www.vim.org/docs.php)
- [Vim 配置](https://github.com/amix/vimrc)
- [豆包AI Rocky Linux 10 如何安装和升级 vim](./RockyLinux10上安装和升级Vim.md)

