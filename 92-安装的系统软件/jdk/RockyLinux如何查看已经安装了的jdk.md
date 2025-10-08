# 查看 Rocky Linux 已安装的 JDK

在 Rocky Linux 上查看已安装的 JDK 有几种方法，从简单到详细依次如下：

## 1. 查看默认 Java 版本
```bash
java -version
```
如果安装了多个版本，这会显示当前默认使用的 JDK。

## 2. 列出所有已安装的 JDK
### 使用 alternatives（推荐）
```bash
alternatives --list | grep -E 'java|javac'
```
这会显示系统中所有已注册的 Java 命令及对应的路径。

### 使用 rpm/dnf（适用于系统包安装）
```bash
rpm -qa | grep -E 'java|jdk|jre'
```
或
```bash
dnf list installed | grep -E 'java|jdk|jre'
```

## 3. 查看所有 Java 可执行文件位置
```bash
which -a java javac
```

## 4. 管理默认 JDK 版本
```bash
alternatives --config java
alternatives --config javac
```
这可以切换系统默认使用的 JDK 版本。

## 5. 检查环境变量
```bash
echo $JAVA_HOME
```
如果有值，说明可能配置了自定义 JDK 路径。

## 常见问题排查
- 如果命令不存在，说明没有安装 JDK 或未配置环境变量
- 可以在 `/usr/lib/jvm/` 目录查看所有已安装的 JDK
- 如果找不到 JDK，可以用 `dnf search openjdk` 查找可安装版本

需要我帮你解释如何根据这些信息选择或安装特定版本的 JDK 吗？
