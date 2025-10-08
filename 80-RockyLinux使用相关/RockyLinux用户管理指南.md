# Rocky Linux 用户管理完全指南

## 1. 用户创建与基本管理

### 创建新用户
```bash
# 创建基本用户
sudo useradd username

# 创建用户并指定家目录
sudo useradd -m username

# 创建用户并指定登录shell
sudo useradd -m -s /bin/bash username

# 创建用户并指定用户ID
sudo useradd -m -u 1001 username

# 创建用户并指定用户组
sudo useradd -m -g groupname username
```

### 设置用户密码
```bash
sudo passwd username

# 强制用户下次登录修改密码
sudo passwd -e username
```

### 删除用户
```bash
# 删除用户但保留家目录
sudo userdel username

# 删除用户及其家目录
sudo userdel -r username
```

## 2. 用户信息查看与修改

### 查看用户信息
```bash
# 查看用户基本信息
id username

# 查看用户详细信息
finger username

# 查看用户登录历史
last username

# 查看所有用户列表
cat /etc/passwd
cut -d: -f1 /etc/passwd
```

### 修改用户属性
```bash
# 修改用户名
sudo usermod -l newusername oldusername

# 修改用户家目录
sudo usermod -d /new/home/directory -m username

# 修改用户shell
sudo usermod -s /bin/zsh username

# 修改用户过期时间
sudo usermod -e 2025-12-31 username

# 锁定用户账户
sudo usermod -L username

# 解锁用户账户
sudo usermod -U username
```

## 3. 用户组管理

### 创建用户组
```bash
sudo groupadd groupname

# 创建用户组并指定组ID
sudo groupadd -g 1001 groupname
```

### 管理用户组
```bash
# 将用户添加到组
sudo usermod -aG groupname username

# 将用户从组中移除
sudo gpasswd -d username groupname

# 修改用户的主要组
sudo usermod -g groupname username

# 删除用户组
sudo groupdel groupname
```

### 查看用户组信息
```bash
# 查看用户所属的组
groups username
id -nG username

# 查看所有用户组
cat /etc/group
cut -d: -f1 /etc/group

# 查看组内成员
getent group groupname
```

## 4. 权限管理

### Sudo 权限管理
```bash
# 编辑 sudoers 文件
sudo visudo

# 添加用户到 sudoers
username ALL=(ALL) ALL
username ALL=(ALL) NOPASSWD: ALL  # 免密码 sudo

# 或者将用户添加到 wheel 组（通常已配置 sudo 权限）
sudo usermod -aG wheel username
```

### 文件权限管理
```bash
# 修改文件所有者
sudo chown username:groupname filename

# 修改目录所有者
sudo chown -R username:groupname directory

# 修改文件权限
chmod 755 filename
chmod u+x filename
chmod g-w filename
```

## 5. 高级用户管理

### 批量创建用户
```bash
# 创建用户列表文件 users.txt，每行一个用户名
# 使用脚本批量创建
while IFS= read -r user; do
    sudo useradd -m "$user"
    echo "$user:password123" | sudo chpasswd
    echo "Created user: $user"
done < users.txt
```

### 用户密码策略
```bash
# 查看密码策略
sudo cat /etc/login.defs | grep -E 'PASS_MAX_DAYS|PASS_MIN_DAYS|PASS_WARN_AGE'

# 修改密码策略（编辑配置文件）
sudo vim /etc/login.defs
```

### 用户资源限制
```bash
# 编辑限制配置文件
sudo vim /etc/security/limits.conf

# 添加限制示例
username hard nofile 1024
username soft nofile 512
```

## 6. 实用命令

### 查看当前登录用户
```bash
who
w
users
```

### 切换用户
```bash
su - username  # 切换用户并加载环境变量
sudo -u username command  # 以指定用户执行命令
```

### 用户会话管理
```bash
# 查看用户进程
ps -u username

# 终止用户所有进程
sudo pkill -u username
```

## 7. 安全最佳实践

1. **强密码策略**：设置密码复杂度要求
2. **定期审计**：定期检查用户和权限设置
3. **最小权限原则**：只授予必要的权限
4. **禁用不用的账户**：及时锁定或删除不用的用户
5. **使用 sudo 替代 root**：避免直接使用 root 登录

这些命令和操作涵盖了 Rocky Linux 系统中用户管理的主要方面，可以满足日常系统管理的需求。
