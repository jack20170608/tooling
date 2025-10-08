在 Rocky Linux 上永久关闭 SELinux 的方法如下：

## 临时关闭 SELinux（立即生效，重启后失效）

```bash
# 临时 SELinux 切换到 permissive 模式（警告但不阻止）
sudo setenforce 0

# 查看当前 SELinux 状态
getenforce
```

## 永久关闭 SELinux（需要重启）

### 方法一：修改配置文件

```bash
# 编辑 SELinux 配置文件
sudo vim /etc/selinux/config

# 或者使用 nano 编辑器
sudo nano /etc/selinux/config
```

在文件中找到以下行：
```
SELINUX=enforcing
```

修改为：
```
SELINUX=disabled
```

### 方法二：使用 sed 命令直接修改（更快捷）

```bash
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
```

### 方法三：使用 grubby 修改内核引导参数（推荐）

```bash
# 永久添加 selinux=0 参数到内核引导选项
sudo grubby --update-kernel=ALL --args="selinux=0"

# 验证修改
grubby --info=ALL | grep args
```

## 应用更改

修改完成后，需要重启系统才能生效：

```bash
sudo reboot
```

## 验证 SELinux 状态

系统重启后，验证 SELinux 是否已关闭：

```bash
# 方法一
getenforce

# 方法二
sestatus

# 方法三
cat /etc/selinux/config | grep SELINUX=
```

如果显示 `Disabled` 或 `Permissive`，则表示 SELinux 已成功关闭。

## 注意事项

1. **安全风险**：关闭 SELinux 会降低系统安全性，请谨慎操作。
2. **替代方案**：如果只是需要临时解决某个问题，可以考虑：
  - 将 SELinux 设置为 permissive 模式
  - 为特定服务创建适当的 SELinux 策略
3. **备份**：在修改重要配置文件前，建议先备份备份：
   ```bash
   sudo cp /etc/selinux/config /etc/selinux/config.bak
   ```

选择哪种方法取决于您的具体需求。如果只是临时测试，建议使用临时关闭的方法；如果确实确实需要永久关闭 SELinux，则使用永久关闭的方法。
