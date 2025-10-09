# valkey

Valkey 是一个开源的高性能键值数据存储系统，采用 BSD 许可证。

## 安装
请参考[install.sh](install-valkey.sh)

## 配置和启动
复制本地的配置文件模板[valkey-prod.conf](./conf/valkey-prod.conf)到 `/appvol/ilovemyhome/config/valkey/valkey.conf`，并根据需要进行修改：

```shell
scp valkey-prod.conf sys20://appvol/ilovemyhome/config/valkey/valkey.conf
```



## 参考资料
- [valkey.io](https://valkey.io/topics/installation/)
- [豆包AI-Valkey简介](豆包AI-Valkey全面解析-Redis开源分支的技术与生态革命.md)
- [豆包AI-Valkey Server典型配置文件解释](豆包AI-Valkey-Server典型生产环境配置文件.md)
