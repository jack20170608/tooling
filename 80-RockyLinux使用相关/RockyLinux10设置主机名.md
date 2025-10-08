# Rocky Linux 10 配置主机名

以下是在 Rocky Linux 10 中配置主机名的几种方法：

## 一、查看当前主机名
```bash
hostnamectl
```

## 二、临时修改主机名（重启后失效）
```bash
sudo hostname new-hostname
```

## 三、永久修改主机名（推荐）

### 方法1：使用 hostnamectl 命令（推荐）
```bash
# 设置静态主机名
sudo hostnamectl set-hostname server01.example.com

# 仅设置短主机名
sudo hostnamectl set-hostname server01 --static

# 同时设置pretty名称（用于显示）
sudo hostnamectl set-hostname "Web Server 01" --pretty
```

### 方法2：编辑配置文件
```bash
sudo nano /etc/hostname
```
写入新主机名后保存，然后重启系统。

## 四、配置 /etc/hosts 文件
```bash
sudo nano /etc/hosts
```

添加类似以下内容：
```
127.0.0.1   localhost
127.0.1.1   server01.example.com server01
```

## 五、验证修改
```bash
hostnamectl
hostname -f   # 查看FQDN
```

## 六、修改云服务器主机名
某些云平台可能需要在控制面板和实例中同时修改主机名，然后执行：
```bash
sudo hostnamectl set-hostname new-hostname
```

## 七、常见问题
- **SELinux问题**：如果修改后遇到问题，尝试：
  ```bash
  sudo restorecon -v /etc/hostname
  ```
- **云实例问题**：部分云实例可能需要安装特定包才能保存主机名：
  ```bash
  sudo dnf install -y cloud-init
  ```

需要我帮你解释主机名的不同类型（静态、瞬态、pretty）或它们在网络配置中的作用吗？
