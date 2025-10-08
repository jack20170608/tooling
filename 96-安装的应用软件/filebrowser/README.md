# 设置和安装 FileBrowser

## 1. 下载和安装
使用脚本 [install.sh](install.sh) 安装 filebrowser 2.43.0, 这里面需要配置环境变量 
`APP_INSTALL_ROOT`, `APP_RUNTIME_ROOT`, `APP_BIN`, `APP_CONFIG_ROOT`, `APP_LOG_ROOT`, `APP_DATA_ROOT`

### 参考
- [https://filebrowser.org/installation](https://filebrowser.org/installation)

## 2. 配置和启动

```shell
mkdir -pv ${APP_CONFIG_ROOT}/filebrowser \
&& mkdir -pv ${APP_LOG_ROOT}/filebrowser \
&& mkdir -pv ${APP_DATA_ROOT}/filebrowser
```

启动请参考 [./start-filebrowser.sh](start-filebrowser.sh)
