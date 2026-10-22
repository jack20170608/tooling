# 数据库服务器
数据库服务器（Database Server）是专门用于存储、管理、处理和维护数据库，并为客户端应用提供数据访问服务的计算机系统或软件程序。

## 1. 服务器规格

```text
OS : RockLinux 10.1, 2CPU, 8G Memory, 500GB SSD Disk
```

### 1.1 服务器规格表

| 资源配置情况       | 规格                                 | 说明           |
|--------------|------------------------------------|--------------|
| Architecture | x86_64                             | x86_64架构     |
| CPU          | 2 core                             | 2个CPU核心      |
| Memory       | 8G                                 | 8GB 内存       |
| Storage      | 500GB SSD Disk                     | 500GB SSD 硬盘 |
| Hostname     | db20.ilovemyhome.top               |              |
| 网络           | NAT,HostOnly                       | NAT 网络       |
| OS           | Rocky Linux 10.0 (Red Quartz)      |              |
| Kernel       | Linux 6.12.0-55.27.1.el10_0.x86_64 |              |

这里可以参考[豆包AI的回答 Rocky Linux 10 查看硬件情况](../80-RockyLinux使用相关/RockyLinux10查看硬件情况.md)
常见的命令包括如下:

```shell
## hostnamectl: 查看系统与硬件架构
[root@db20 ~]# hostnamectl
     Static hostname: db20.ilovemyhome.top
## lscpu：查看 CPU 详细信息
[root@db20 ~]# lscpu
Architecture:             x86_64
  CPU op-mode(s):         32-bit, 64-bit
  Address sizes:          45 bits physical, 48 bits virtual
  Byte Order:             Little Endian
## free：查看内存使用与总量
[root@db20 ~]# free -h
               total        used        free      shared  buff/cache   available
Mem:           7.5Gi       542Mi       6.9Gi       9.1Mi       322Mi       6.9Gi
Swap:          7.8Gi          0B       7.8Gi
## lsblk：查看磁盘与分区信息
[root@db20 ~]# lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sr0          11:0    1  1024M  0 rom
nvme0n1     259:0    0   500G  0 disk
├─nvme0n1p1 259:1    0     1M  0 part
├─nvme0n1p2 259:2    0     1G  0 part /boot
└─nvme0n1p3 259:3    0   499G  0 part
  ├─rl-root 253:0    0    70G  0 lvm  /
  ├─rl-swap 253:1    0   7.8G  0 lvm  [SWAP]
  └─rl-home 253:2    0 421.2G  0 lvm  /home
## df -h：查看文件系统使用情况
[root@db20 ~]# df -h
Filesystem           Size  Used Avail Use% Mounted on
/dev/mapper/rl-root   70G  2.4G   68G   4% /
devtmpfs             4.0M     0  4.0M   0% /dev
tmpfs                3.8G     0  3.8G   0% /dev/shm
tmpfs                1.5G  9.1M  1.5G   1% /run
tmpfs                1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
/dev/nvme0n1p2       960M  247M  714M  26% /boot
/dev/mapper/rl-home  421G  8.1G  413G   2% /home
tmpfs                1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
tmpfs                765M  4.0K  765M   1% /run/user/1000
tmpfs                765M  4.0K  765M   1% /run/user/0
```

### 1.2 网络配置情况
网络配置表

| 网卡ID   | 虚拟网络   | 虚拟网络类型   | IP              | 网关         | DNS         |
|--------|--------|----------|-----------------|------------|-------------|
| ens160 | VmNet8 | NAT      | 10.10.10.20/8   | 10.10.10.2 | 10.10.10.10 |
| ens224 | VmNet1 | HostOnly | 172.16.10.20/16 | N/A        | N/A         |

路由表情况
```shell
[root@db20 ~]# ip route
default via 10.10.10.2 dev ens160 proto static metric 100
10.0.0.0/8 dev ens160 proto kernel scope link src 10.10.10.20 metric 100
172.16.0.0/16 dev ens224 proto kernel scope link src 172.16.10.20 metric 101
```

## 2. 关系型与非关系型数据库

关系型数据库（Relational Database）和非关系型数据库（NoSQL Database）是两种不同类型的数据库管理系统，
它们在数据存储结构、查询方式以及适用场景等方面存在显著差异。

### 3.1 关系型数据库 (RDBMS)

- **定义**：基于关系模型的数据库，使用行和列来存储和组织数据。
- **特点**：
  - 使用结构化查询语言（SQL）进行数据操作。
  - 支持ACID事务特性（原子性、一致性、隔离性、持久性），确保数据完整性。
  - 数据以表格形式存储，表之间可以通过外键建立关联。
- **常见示例**：
  - MySQL
  - PostgreSQL
  - Oracle Database
  - Microsoft SQL Server

### 3.2 非关系型数据库 (NoSQL)

- **定义**：泛指非传统关系型的数据存储系统，通常用于处理大规模分布式数据。
- **特点**：
  - 不依赖固定的表结构，可以灵活地存储各种格式的数据。
  - 水平扩展能力强，适合大数据量和高并发访问的需求。
  - 大多数不支持标准的SQL查询语言，而是采用特定的API或查询机制。
- **常见类型及示例**：
  - **文档数据库**：如 MongoDB、Couchbase，适用于内容管理、实时分析等场景。
  - **键值存储**：如 Redis、Amazon DynamoDB，适合缓存、会话存储等高性能读写操作。
  - **列族数据库**：如 Cassandra、HBase，常用于日志处理、时间序列数据等宽表场景。
  - **图数据库**：如 Neo4j、Amazon Neptune，专为复杂网络结构数据设计，例如社交网络、推荐系统。

选择哪种类型的数据库取决于具体的应用需求，包括数据结构、性能要求、扩展性等因素。

## 3. 软件配置列表
准备安装开源的数据库软件包括: PostgresSQL, MongoDB, Redis

## 4. 安装PostgreSQL实现关系型数据库自由
请参考[PostgreSQL安装和配置指南](../92-安装的系统软件/postgresql/README.md)

## 5. 安装valkey实现键值存储数据库自由
请参考[valkey的安装和配置指南](../92-安装的系统软件/valkey/README.md)

## 7. 安装时间序列数据库

## 参考资料
- [豆包AI-数据库服务器核心概念架构与实践指南](豆包AI数据库服务器核心概念架构与实践指南.md)
