# valkey

Valkey 是一个开源的高性能键值数据存储系统，采用 BSD 许可证。

## 安装
请参考[install.sh](install_valkey.sh)

## 配置和启动
复制本地的配置文件模板[valkey-prod.conf](./conf/valkey-prod.conf)到 `/appvol/ilovemyhome/config/valkey/valkey-prod.conf`，并根据需要进行修改：

```shell
scp valkey-prod.conf sys20://appvol/ilovemyhome/config/valkey/valkey.conf
```
复制本地的[app_valkey.sh](./app_valkey.sh)到 `/appvol/ilovemyhome/bin/app_valkey.sh`，并赋予执行权限：

```shell
## Valkey Server的启动/停止/状态检查脚本位于 `/appvol/ilovemyhome/bin/app_valkey.sh`。
[jack@sys20 bin]$ /appvol/ilovemyhome/bin/app_valkey.sh start
[jack@sys20 bin]$ /appvol/ilovemyhome/bin/app_valkey.sh status
[jack@sys20 bin]$ /appvol/ilovemyhome/bin/app_valkey.sh stop
```

## 测试连接
Valkey 提供了一个名为 `valkey-cli` 的命令行客户端工具，用于与 Valkey 服务器进行交互。以下是一些基本的测试命令：

```shell
[jack@sys20 bin]$ source set_valkey_envs.sh \
> && $VALKEY_BIN/valkey-cli -h localhost -p 6379 -a 1
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
localhost:6379> PING
PONG
```

## 常规与性能测试
参考[test_valkey.sh](./test_valkey.sh)



## 参考资料
- [valkey.io](https://valkey.io/topics/installation/)
- [豆包AI-Valkey简介](豆包AI-Valkey全面解析-Redis开源分支的技术与生态革命.md)
- [豆包AI-Valkey Server典型配置文件解释](豆包AI-Valkey-Server典型生产环境配置文件.md)
