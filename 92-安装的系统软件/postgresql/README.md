# postgresql

ostgreSQL 是一款功能强大的开源对象关系型数据库系统，以其稳定性、可靠性和丰富的功能集而闻名。它是全球最先进的开源数据库之一，广泛应用于企业级应用、Web 服务和数据分析场景。


## 安装
这次文档没有采用dnf来安装，而是采用手动下载RPM包的方式来定制化安装。

| 对比维度            | `postgresql18-libs`（依赖库包） | `postgresql18`（基础工具包）         | `postgresql18-server`（服务器端包）               | `postgresql18-contrib`（扩展包）                   | `postgresql18-devel`（开发依赖包）                     |
| --------------- | ------------------------- | ----------------------------- | ------------------------------------------ | --------------------------------------------- | ----------------------------------------------- |
| **核心定位**        | 所有包的 “运行依赖基石”             | 客户端 “基础操作工具集”                 | 数据库 “核心运行引擎”                               | 功能 “扩展增强包”                                    | 开发 “编译依赖资源库”                                    |
| **是否必需（最小化安装）** | ✅ 必需（所有包依赖它）              | ✅ 客户端必需，服务器端可选                | ✅ 服务器端必需，纯客户端可选                            | ❌ 非必需（按需安装）                                   | ❌ 非必需（仅开发场景需）                                   |
| **核心内容**        | 动态库（`libpq.so` 等）、配置文件    | 客户端工具（`psql`/`pg_dump`）、基础动态库 | 服务器程序（`postmaster`）、初始化工具（`initdb`）、数据目录模板 | 扩展模块（`pg_stat_statements`）、运维工具（`pg_dumpall`） | 头文件（`libpq-fe.h`）、静态库（`libpq.a`）、`pg_config` 脚本 |
| **依赖关系**        | 无依赖（独立包）                  | 依赖 `postgresql18-libs`        | 依赖 `postgresql18` + `postgresql18-libs`    | 依赖 `postgresql18` + `postgresql18-libs`       | 依赖 `postgresql18` + `postgresql18-libs`         |
| **典型适用场景**      | 所有场景（客户端 / 服务器端 / 扩展运行）   | 纯客户端操作（连接、单库备份）               | 搭建数据库服务器（启动服务、管理数据）                        | 启用官方扩展（性能分析、全文检索）                             | 编译第三方程序（C 客户端）、开发自定义扩展                          |
| **自定义安装关键作用**   | 提供动态库，确保其他包可运行            | 提供基础客户端工具，用于连接测试              | 提供服务器核心程序，初始化自定义数据目录（`/opt/pg18/data`）     | 提供扩展模块，增强数据库功能（如慢 SQL 分析）                     | 提供编译资源，支持开发定制化工具或扩展                             |



## 参考资料
- [postgresql官方文档](https://www.postgresql.org/)
- [postgresql download](https://www.postgresql.org/download/linux/redhat/)
- [postgresql 18 download](https://download.postgresql.org/pub/repos/yum/18/redhat/rhel-10-x86_64/)
- [豆包AI postgresql 简单介绍](reference/豆包AI-PostgreSQL简单介绍.md)
- [豆包AI-PostgreSQL18核心包对比分析](reference/豆包AI-PostgreSQL18核心包对比分析.md)
