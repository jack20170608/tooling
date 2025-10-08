# Rocky Linux 10 安装和配置 dnsmasq

## 安装 dnsmasq

```bash
# 安装 dnsmasq
sudo dnf install dnsmasq -y

# 启动并设置开机自启
sudo systemctl enable --now dnsmasq

# 检查状态
sudo systemctl status dnsmasq
```

## 基础配置

### 1. 备份配置文件
```bash
sudo cp /etc/dnsmasq.conf /etc/dnsmasq.conf.bak
```

### 2. 编辑配置文件
```bash
sudo nano /etc/dnsmasq.conf
```

添加以下内容：
```
# 监听地址
listen-address=127.0.0.1,192.168.1.10  # 替换为你的服务器IP

# 不读取/etc/resolv.conf
no-resolv

# DNS上游服务器
server=1.1.1.1
server=8.8.8.8

# 缓存大小
cache-size=1000

# 自定义域名解析
address=/internal.example.com/192.168.1.50
host-record=server.local,192.168.1.100
```

### 3. 重启服务
```bash
sudo systemctl restart dnsmasq
```

## 配置防火墙

```bash
# 开放DNS端口
sudo firewall-cmd --add-service=dns --permanent
sudo firewall-cmd --reload
```

## 测试DNS解析

```bash
# 本地测试
dig @127.0.0.1 www.baidu.com

# 测试自定义域名
dig @127.0.0.1 server.local
```

## 高级配置选项

### 配置DHCP服务
在dnsmasq.conf中添加：
```
# DHCP配置
dhcp-range=192.168.1.100,192.168.1.200,255.255.255.0,12h
dhcp-option=3,192.168.1.1  # 网关
dhcp-option=6,192.168.1.10  # DNS服务器
```

### 使用hosts文件管理解析
```bash
# 创建自定义hosts文件
sudo nano /etc/dnsmasq.hosts

# 添加内容
192.168.1.20 webserver.local
192.168.1.21 dbserver.local

# 在dnsmasq.conf中引用
addn-hosts=/etc/dnsmasq.hosts
```

### 日志配置
```bash
# 在dnsmasq.conf中添加
log-queries
log-facility=/var/log/dnsmasq.log

# 设置日志轮转
sudo nano /etc/logrotate.d/dnsmasq
```

添加以下内容：
```
/var/log/dnsmasq.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    postrotate
        systemctl restart dnsmasq >/dev/null 2>&1 || true
    endscript
}
```

## 客户端配置

修改客户端的DNS设置，指向你的dnsmasq服务器IP：
```bash
# 修改网络配置文件
sudo nano /etc/resolv.conf

# 添加
nameserver 192.168.1.10  # 替换为你的服务器IP
```

需要注意的是，如果你使用NetworkManager，它可能会自动覆盖resolv.conf文件。你需要在NetworkManager配置中设置DNS服务器。

想了解如何配置更复杂的DNS场景，比如条件转发或缓存优化吗？
