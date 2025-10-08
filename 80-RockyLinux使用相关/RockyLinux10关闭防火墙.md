# Rocky Linux 10 关闭防火墙

Rocky Linux 10 默认使用 firewalld 作为防火墙管理工具。以下是关闭防火墙的方法：

## 临时关闭防火墙

```bash
# 停止 firewalld 服务
sudo systemctl stop firewalld

# 检查状态
sudo firewall-cmd --state
# 或
sudo systemctl status firewalld
```

**注意：** 这种方式在系统重启后会自动恢复防火墙状态。

## 永久关闭防火墙

```bash
# 停止并禁用 firewalld 服务
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# 检查是否已禁用
sudo systemctl is-enabled firewalld
```

## 关闭 SELinux（可选）

```bash
# 临时关闭
sudo setenforce 0

# 永久关闭（需重启生效）
sudo sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# 检查状态
getenforce
```

## 重新启用防火墙

```bash
# 启用并启动 firewalld 服务
sudo systemctl enable --now firewalld

# 检查状态
sudo systemctl status firewalld
```

## 常见问题

- 如果命令提示找不到 firewalld，可能需要先安装：
  ```bash
  sudo dnf install -y firewalld
  ```

- 云服务器环境下，还需检查云平台的安全组设置，因为它可能会影响网络访问。

需要我帮你解释防火墙规则管理的其他方面吗？比如如何只开放特定端口而不是完全关闭防火墙？
