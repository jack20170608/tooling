# JDK

这里我们为了方便我们切换不同的JDK版本，没有采用包管理器的安装方式，而是手动下载和解压安装的方式。

## 需要首先卸载已经安装了的jdk
```shell
## 列出所有已安装的jdk
[jack@dns10 .ssh]$  dnf list installed | grep -E 'java|jdk'
java-21-openjdk.x86_64                               1:21.0.8.0.9-1.el10            @appstream
java-21-openjdk-devel.x86_64                         1:21.0.8.0.9-1.el10            @appstream
java-21-openjdk-headless.x86_64                      1:21.0.8.0.9-1.el10            @appstream
javapackages-filesystem.noarch                       6.4.0-1.el10                   @appstream
tzdata-java.noarch                                   2025b-1.el10                   @appstream
## 卸载jdk-21
[jack@dns10 .ssh]$ sudo dnf remove java-21-openjdk*
```
由于open-jdk-17的安装包在Rocky Linux 10的源中已经升级到了21。我们这里使用open jdk的zulu的发行版，zulu JDK 是Azul Systems公司提供的OpenJDK发行版。

## 安装完成后的效果
```shell
[jack@dns10 runtime]# ll
total 0
lrwxrwxrwx 1 jack jack 40 Sep 29 20:15 jdk-17 -> /appvol/ilovemyhome/install/jdk-17.0.16/
lrwxrwxrwx 1 jack jack 41 Sep 29 20:31 jdk-21 -> /appvol/ilovemyhome/install/jdk-21.44.17/
lrwxrwxrwx 1 jack jack 39 Sep 29 20:35 jdk-25 -> /appvol/ilovemyhome/install/jdk-25.0.0/

[root@dns10 runtime]# ls -al /etc/profile.d/jdk*
-rw-r--r-- 1 root root 122 Sep 29 20:26 /etc/profile.d/jdk-17.sh
-rw-r--r-- 1 root root 122 Sep 29 20:32 /etc/profile.d/jdk-21.sh
-rw-r--r-- 1 root root 122 Sep 29 20:35 /etc/profile.d/jdk-25.sh

通过执行不同的jdk*.sh来切换当前的jdk版本,默认安装的是jdk-25。
```

## 安装zulu jdk-17
```shell
## 安装zulu jdk-17.0.10
[jack@dns10 .ssh]$ cd /appvol/ilovemyhome/install/ \
&& wget http://10.10.10.10/ilovemyhome/download/jdk/zulu17.60.17-ca-jdk17.0.16-linux_x64.tar.gz \
&& tar -xzvf zulu17.60.17-ca-jdk17.0.16-linux_x64.tar.gz \
&& mv zulu17.60.17-ca-jdk17.0.16-linux_x64 jdk-17.0.16 \
&& rm -f /appvol/ilovemyhome/runtime/jdk-17 \
&& ln -s /appvol/ilovemyhome/install/jdk-17.0.16/ /appvol/ilovemyhome/runtime/jdk-17 \
&& rm -f zulu17.60.17-ca-jdk17.0.16-linux_x64.tar.gz 

## 设置环境变量
[root@dns10 ~]# cat <<'EOF' > "/etc/profile.d/jdk-17.sh"
export JAVA_17_HOME=/appvol/ilovemyhome/runtime/jdk-17
export PATH=$JAVA_17_HOME/bin:$PATH
export JAVA_HOME=$JAVA_17_HOME
EOF

[root@dns10 ~]# source /etc/profile.d/jdk-17.sh
[root@dns10 ~]# java -version
openjdk version "17.0.16" 2025-07-15 LTS
...
```

## 安装zulu jdk-21
```shell
## 安装zulu jdk-21.44.17
[jack@dns10 .ssh]$ cd /appvol/ilovemyhome/install/ \
&& wget http://10.10.10.10/ilovemyhome/download/jdk/zulu21.44.17-ca-jdk21.0.8-linux_x64.tar.gz \
&& tar -xzvf zulu21.44.17-ca-jdk21.0.8-linux_x64.tar.gz \
&& mv zulu21.44.17-ca-jdk21.0.8-linux_x64 jdk-21.44.17 \
&& rm -f /appvol/ilovemyhome/runtime/jdk-21 \
&& ln -s /appvol/ilovemyhome/install/jdk-21.44.17/ /appvol/ilovemyhome/runtime/jdk-21 \
&& rm -f zulu21.44.17-ca-jdk21.0.8-linux_x64.tar.gz

## 设置环境变量
[root@dns10 ~]# cat <<'EOF' > "/etc/profile.d/jdk-21.sh"
export JAVA_21_HOME=/appvol/ilovemyhome/runtime/jdk-21
export PATH=$JAVA_21_HOME/bin:$PATH
export JAVA_HOME=$JAVA_21_HOME
EOF

[root@dns10 ~]# source /etc/profile.d/jdk-21.sh
[root@dns10 ~]#  java -version
openjdk version "21.0.8" 2025-07-15 LTS
...
```

## 安装zulu jdk-25
```shell
## 安装zulu jdk-25.28.85
[jack@dns10 .ssh]$ cd /appvol/ilovemyhome/install/ \
&& wget http://10.10.10.10/ilovemyhome/download/jdk/zulu25.28.85-ca-jdk25.0.0-linux_x64.tar.gz \
&& tar -xzvf zulu25.28.85-ca-jdk25.0.0-linux_x64.tar.gz \
&& mv zulu25.28.85-ca-jdk25.0.0-linux_x64 jdk-25.0.0 \
&& rm -f /appvol/ilovemyhome/runtime/jdk-25 \
&& ln -s /appvol/ilovemyhome/install/jdk-25.0.0/ /appvol/ilovemyhome/runtime/jdk-25 \
&& rm -f zulu25.28.85-ca-jdk25.0.0-linux_x64.tar.gz

## 设置环境变量
[jack@dns10 ~]# sudo cat <<'EOF' > "/etc/profile.d/jdk-25.sh"
export JAVA_25_HOME=/appvol/ilovemyhome/runtime/jdk-25
export PATH=$JAVA_25_HOME/bin:$PATH
export JAVA_HOME=$JAVA_25_HOME
EOF

[root@dns10 ~]# source /etc/profile.d/jdk-25.sh
[root@dns10 install]#  java -version
openjdk version "25" 2025-09-16 LTS
...
```


##  参考资料
- [Download Azul JDKs](https://www.azul.com/downloads/#zulu)
- [Open Jdk](https://openjdk.java.net/)
- [zulu-17.60.17-ca-jdk17.0.16-linux_x64.tar.gz](https://cdn.azul.com/zulu/bin/zulu17.60.17-ca-jdk17.0.16-linux_x64.tar.gz)
- [zulu-21.44.17-ca-jdk21.0.8-linux_x64.tar.gz](https://cdn.azul.com/zulu/bin/zulu21.44.17-ca-jdk21.0.8-linux_x64.tar.gz)
- [zulu-25.28.85-ca-jdk25.0.0-linux_x64.tar.gz](https://cdn.azul.com/zulu/bin/zulu25.28.85-ca-jdk25.0.0-linux_x64.tar.gz)
- [豆包AI RockyLinux如何查看已经安装了的jdk](RockyLinux如何查看已经安装了的jdk.md)
- [豆包AI 在Rocky Linux上切换JDK版本](在RockyLinux上切换JDK版本.md)
