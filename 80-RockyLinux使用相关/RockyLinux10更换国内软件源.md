# Rocky Linux 10 最新适配：阿里云镜像源配置方案（修复版本不适配问题）

## 一、Rocky Linux 10 核心变化说明（为什么旧步骤失效）

1. **文件名标准化**：默认 repo 文件从大写（`Rocky-BaseOS.repo`）改为全小写（`rocky-baseos.repo`），旧步骤的 `Rocky-*.repo` 匹配不到文件；

2. **仓库结构优化**：`rocky-repos` 包生成的 repo 文件路径和字段更精简，官方源地址从 `http://dl.rockylinux.org` 改为 `https://dl.rockylinux.org`；

3. **镜像同步适配**：阿里云已同步 Rocky 10 镜像至 `https://mirrors.aliyun.com/rockylinux/10/` 路径（含 x86\_64 和 ARM 架构）。

## 二、全新配置步骤（分「有基础 repo 文件」和「无 repo 文件」两种场景）

### 场景 1：系统已有默认小写 repo 文件（多数正常安装场景）

先确认系统现有 repo 文件：
```shell
#查看 Rocky 10 默认 repo 文件（全小写）
ls /etc/yum.repos.d/rocky*.repo
```

#### 步骤 1：备份原有配置
```
# 备份所有 rocky 相关 repo 文件，避免误操作无法恢复
sudo mkdir -p /etc/yum.repos.d/backup
sudo mv /etc/yum.repos.d/rocky*.repo /etc/yum.repos.d/backup/
```

#### 步骤 2：一键生成阿里云 repo 配置（适配小写文件名）

直接创建适配 Rocky 10 的阿里云 repo 文件，覆盖基础仓库需求：

```shell
# 创建阿里云 baseos + appstream + extras 综合 repo 文件
sudo tee /etc/yum.repos.d/rocky-aliyun.repo <<-'EOF'
[baseos]
name=Rocky Linux $releasever - BaseOS - Aliyun
baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/BaseOS/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial

[appstream]
name=Rocky Linux $releasever - AppStream - Aliyun
baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/AppStream/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial

[extras]
name=Rocky Linux $releasever - Extras - Aliyun
baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/extras/$basearch/os/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial
EOF
```

### 场景 2：系统无任何 rocky\*.repo 文件（最小化安装 / 误删场景）

无需依赖 `rocky-repos` 包，直接通过阿里云临时源重建基础环境：

#### 步骤 1：创建临时阿里云源（用于安装必要工具）

```shell
sudo tee /etc/yum.repos.d/temp-aliyun.repo <<-'EOF'
[temp-aliyun-base]
name=Temp Rocky 10 Base - Aliyun
baseurl=https://mirrors.aliyun.com/rockylinux/10/BaseOS/$basearch/os/
gpgcheck=0  # 临时关闭验证，仅用于初始化
enabled=1
EOF
```

#### 步骤 2：安装 repo 管理工具并删除临时源
```shell
# 安装 repo 文件生成工具（Rocky 10 已预装，若缺失则自动安装）
sudo dnf install -y dnf-utils --refresh

# 删除临时源，避免冲突
sudo rm /etc/yum.repos.d/temp-aliyun.repo
```

#### 步骤 3：执行场景 1 的「步骤 2」，生成阿里云正式 repo 文件

## 三、配置 EPEL 源（Rocky 10 适配版）

Rocky 10 已支持 EPEL 10 源，直接配置阿里云镜像：

```shell
sudo dnf install epel-release
```

## 四、生效与验证（关键步骤，确保配置成功）

### 1. 清理缓存并重建阿里云索引

```shell
# 清理系统残留的官方源缓存
sudo dnf clean all

# 重建阿里云镜像缓存（首次执行需等待 10-30 秒）
sudo dnf makecache
```

### 2. 三重验证法（确认版本适配）

```shell
# 验证1：查看已启用的仓库，确认全是阿里云地址
sudo dnf repolist enabled | grep -E "baseos|appstream|extras|epel"

# 验证2：检查 repo 文件是否适配 Rocky 10（小写+正确路径）
cat /etc/yum.repos.d/rocky-aliyun.repo | grep "baseurl"
# 正确输出：baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/BaseOS/$basearch/os/

# 验证3：测试软件安装（观察下载地址含 aliyun）
sudo dnf install -y wget -v
sudo dnf install -y htop
```

## 恢复官方源（如需）

```shell
# 删除阿里云 repo 文件
sudo rm /etc/yum.repos.d/rocky-aliyun.repo /etc/yum.repos.d/epel*.repo

# 恢复备份的默认 repo 文件
sudo mv /etc/yum.repos.d/backup/* /etc/yum.repos.d/

# 重建官方源缓存
sudo dnf clean all && sudo dnf makecache
```

## 常见问题
### “gpgkey 验证失败”

一种解决方案是手动导入 GPG 密钥：
```shell
sudo rpm --import https://mirrors.aliyun.com/rockylinux/10/RPM-GPG-KEY-rockyofficial
```

另外一种方法就是取消 gpgkey 验证，设置`gpgcheck=0` 但是这不是一个推荐的做法，因为它会降低系统的安全性。
```shell
## /etc/yum.repos.d/rocky-aliyun.repo
[baseos]
name=Rocky Linux $releasever - BaseOS - Aliyun
baseurl=https://mirrors.aliyun.com/rockylinux/$releasever/BaseOS/$basearch/os/
gpgcheck=0
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rockyofficial

```


> （注：文档部分内容可能由 AI 生成）
