# Rocky Linux 10 网络及静态IP设置

Rocky Linux 10 使用 NetworkManager 管理网络，以下是设置静态IP的方法：

## 一、查看当前网络接口

```bash
nmcli device status
```

记下你要配置的接口名称（如 `ens18`）。

## 二、使用 nmcli 命令配置（推荐）

### 1. 查看当前配置
```bash
nmcli connection show
```

### 2. 编辑连接（推荐方法）

**方法A：交互式编辑**
```bash
sudo nmcli connection edit "连接名称"
# 进入编辑模式后执行：
nmcli> set ipv4.method manual
nmcli> set ipv4.addresses 192.168.1.100/24
nmcli> set ipv4.gateway 192.168.1.1
nmcli> set ipv4.dns "8.8.8.8 114.114.114.114"
nmcli> save
nmcli> quit
```

**方法B：直接命令修改**
```bash
sudo nmcli connection modify "连接名称" \
  ipv4.method manual \
  ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.dns "8.8.8.8 114.114.114.114" \
  ipv4.ignore-auto-dns yes
```

### 3. 激活配置
```bash
sudo nmcli connection down "连接名称"
sudo nmcli connection up "连接名称"
```

### 4. 验证
```bash
ip addr show 接口名
ping -c 4 baidu.com
```

## 三、直接编辑配置文件

### 1. 找到配置文件
```bash
ls /etc/NetworkManager/system-connections/
```

### 2. 编辑文件（示例）
```ini
[connection]
id=ens18
type=ethernet
interface-name=ens18

[ethernet]
mac-address-blacklist=

[ipv4]
method=manual
address1=192.168.1.100/24,192.168.1.1
dns=8.8.8.8;114.114.114.114;
ignore-auto-dns=true

[ipv6]
method=ignore

[proxy]
```

### 3. 重载配置
```bash
sudo chmod 600 /etc/NetworkManager/system-connections/你的文件
sudo nmcli connection reload
sudo nmcli connection up "连接名称"
```

## 四、图形界面配置

1. 打开 "Settings" → "Network"
2. 点击对应接口的齿轮图标
3. IPv4 标签页选择 "Manual"
4. 填写地址、子网掩码、网关和DNS
5. 点击 "Apply" 保存

## 五、特殊情况

### 1. 多IP配置
```bash
sudo nmcli connection modify "连接名称" \
  ipv4.addresses "192.168.1.100/24,192.168.1.101/24" \
  ipv4.gateway 192.168.1.1
```

### 2. 配置Bonding/Team
```bash
# 创建bond接口
sudo nmcli connection add type bond con-name bond0 ifname bond0 mode 802.3ad

# 添加从属接口
sudo nmcli connection add type bond-slave con-name bond0-slave1 ifname ens18 master bond0
sudo nmcli connection add type bond-slave con-name bond0-slave2 ifname ens19 master bond0

# 配置IP
sudo nmcli connection modify bond0 ipv4.method manual ipv4.addresses 192.168.1.100/24 ipv4.gateway 192.168.1.1
```

### 3. 配置VLAN
```bash
sudo nmcli connection add type vlan con-name vlan10 ifname vlan10 dev ens18 id 10
sudo nmcli connection modify vlan10 ipv4.method manual ipv4.addresses 192.168.10.100/24
```

需要我帮你解决特定网络环境下的配置问题，或者解释某个配置项的具体含义吗？
