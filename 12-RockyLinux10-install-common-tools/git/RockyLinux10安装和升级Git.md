# Rocky Linux 10 安装和升级 Git

## 安装 Git

```bash
# 更新包索引
sudo dnf check-update

# 安装 Git
sudo dnf install git -y

# 验证安装
git --version
```

## 升级 Git

### 1. 使用默认源升级
```bash
# 检查更新
sudo dnf check-update git

# 升级 Git
sudo dnf upgrade git -y
```

### 2. 使用 IUS 源获取新版本
如果默认源版本过旧，可以使用 IUS 源：

```bash
# 安装 IUS 源
sudo dnf install https://repo.ius.io/ius-release-el10.rpm -y

# 安装较新版本的 Git
sudo dnf install git258 -y

# 验证版本
git --version
```

## 配置 Git

```bash
git config --global user.name "Your Name"
git config --global user.email "youremail@example.com"
```

## 可选组件

```bash
# 大文件支持
sudo dnf install git-lfs -y

# GUI 工具
sudo dnf install git-gui gitk -y
```

想了解如何使用 Git 管理你的第一个项目，或者如何设置 SSH 密钥与远程仓库连接吗？
