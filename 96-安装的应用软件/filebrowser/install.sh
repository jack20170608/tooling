#!/usr/bin/env bash

## 一键安装 filebrowser 2.43.0
version=2.43.0

mkdir -pv "$APP_INSTALL_ROOT"/filebrowser-"$version" \
&& cd "$APP_INSTALL_ROOT"/filebrowser-"$version" \
&& wget https://github.com/filebrowser/filebrowser/releases/latest/download/linux-amd64-filebrowser.tar.gz \
&& tar -zxvf linux-amd64-filebrowser.tar.gz \
&& rm -f "${APP_RUNTIME_ROOT}"/filebrowser && ln -s "${APP_INSTALL_ROOT}"/filebrowser-"$version" "${APP_RUNTIME_ROOT}"/filebrowser \
&& rm -f "${APP_BIN}"/filebrowser && ln -s $APP_RUNTIME_ROOT/filebrowser/filebrowser "${APP_BIN}"/filebrowser \
&& chmod +x "${APP_BIN}"/filebrowser \
&& filebrowser version

