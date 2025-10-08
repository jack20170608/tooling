# Rocky Linux 10 查看硬件情况

以下是在 Rocky Linux 10 上查看各种硬件信息的常用命令和工具：

## 系统概览

```bash
# 系统信息
uname -a

# 系统详情
cat /etc/os-release
hostnamectl

# 硬件概览
lscpu
free -h
lsblk
df -h
```

## 详细硬件信息

### 主板信息
```bash
# 安装工具
sudo dnf install -y dmidecode pciutils usbutils

# 查看主板信息
sudo dmidecode -t baseboard

# 查看BIOS信息
sudo dmidecode -t bios
```

### CPU信息
```bash
lscpu
cat /proc/cpuinfo | grep -E "model name|cpu MHz|siblings|cores"
```

### 内存信息
```bash
free -h
cat /proc/meminfo
sudo dmidecode -t memory
```

### 硬盘/存储
```bash
lsblk -f
df -h
sudo fdisk -l
```

### 显卡信息
```bash
lspci | grep -E "VGA|3D|Display"
```

### 网络信息
```bash
ip addr
ip link
ethtool eth0  # 替换eth0为你的网卡名
```

### 温度/传感器
```bash
# 安装工具
sudo dnf install -y lm_sensors

# 检测传感器
sudo sensors-detect

# 查看温度
sensors
```

## 图形化工具

```bash
# 安装硬件信息工具
sudo dnf install -y hardinfo

# 启动硬件信息查看器
hardinfo
```

## 快速查看所有硬件信息

```bash
sudo lshw -short
```

想了解如何分析这些硬件信息，或者针对特定硬件（如显卡、硬盘健康状况）进行更详细的诊断吗？
