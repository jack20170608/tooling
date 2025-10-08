# 在 Rocky Linux 上切换 JDK 版本

Rocky Linux 提供了多种方法来切换 JDK 版本，从简单到灵活依次如下：

## 1. 使用 alternatives 系统（推荐）

这是 Rocky Linux/CentOS/RHEL 的标准方法：

```bash
# 查看并选择 java 版本
sudo alternatives --config java

# 查看并选择 javac 版本
sudo alternatives --config javac
```

执行后会看到类似这样的列表：
```
There are 2 programs which provide 'java'.

  Selection    Command
-----------------------------------------------
*+ 1           java-11-openjdk.x86_64 (/usr/lib/jvm/java-11-openjdk-11.0.12.0.7-0.el8_4.x86_64/bin/java)
   2           java-1.8.0-openjdk.x86_64 (/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.302.b08-0.el8_4.x86_64/bin/java)

Enter to keep the current selection[+], or type selection number:
```

**注意**：需要分别配置 `java` 和 `javac` 等命令。

## 2. 使用 scl 工具（适用于软件集合包）

如果你的 JDK 是通过软件集合安装的：

```bash
# 查看可用的软件集合
scl --list

# 临时启用某个版本
scl enable rh-openjdk-17 bash

# 永久启用（添加到配置文件）
echo "source scl_source enable rh-openjdk-17" >> ~/.bashrc
```

## 3. 手动设置 JAVA_HOME（灵活但需谨慎）

适用于手动安装的 JDK 或需要为特定用户/应用设置：

```bash
# 找到 JDK 安装路径
ls /usr/lib/jvm/

# 设置环境变量
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export PATH=$JAVA_HOME/bin:$PATH

# 验证
java -version
```

**永久生效**：
- 全局：`/etc/profile.d/java.sh`
- 用户：`~/.bashrc` 或 `~/.zshrc`

## 4. 为特定应用单独配置

在应用启动脚本中设置 JAVA_HOME，不影响系统全局配置：

```bash
# 示例：Tomcat 启动脚本
JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export JAVA_HOME
exec "$JAVA_HOME/bin/java" -jar app.jar
```

## 常见问题解决

- **命令未找到**：确保已安装 JDK 或配置了正确的 PATH
- **切换后版本不变**：检查是否有其他配置覆盖了 alternatives 设置
- **忘记已安装版本**：使用 `dnf list installed | grep -E 'java|jdk'` 查看

想了解如何安装新的 JDK 版本或为特定项目管理多个 JDK 吗？请参考 [在 Rocky Linux 上安装 JDK](在RockyLinux上安装JDK.md)。

