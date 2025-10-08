#!/usr/bin/env bash

APP_NAME="filebrowser"
APP_LOG_HOME="${APP_LOG_ROOT}/${APP_NAME}"
APP_CONFIG_HOME="${APP_CONFIG_ROOT}/${APP_NAME}"
APP_DATA_HOME="${APP_DATA_ROOT}/${APP_NAME}"

# 应用根目录
APP_WWW_ROOT="${APP_ROOT:-/appvol/ilovemyhome/}"
APP_CONFIG_FILE="${APP_CONFIG_HOME}/${APP_NAME}.json"
APP_DATABASE="${APP_DATA_HOME}/${APP_NAME}.db"

# 生成配置文件
cat > "${APP_CONFIG_FILE}" << EOF
{
  "address": "0.0.0.0",
  "port": 8080,
  "log": "${APP_LOG_HOME}/${APP_NAME}.log",
  "database": "$APP_DATABASE",
  "root": "$APP_WWW_ROOT",
  "allowCommands": false,
  "allowEdit": true,
  "noAuth": true
}
EOF

function start() {
  mkdir -pv "${APP_LOG_HOME}"
  mkdir -pv "${APP_CONFIG_HOME}"
  mkdir -pv "${APP_DATA_HOME}"

  if [ ! -f "${APP_DATABASE}" ]; then
    echo "init database..."
    "${APP_RUNTIME_ROOT}"/${APP_NAME}/filebrowser -c "${APP_CONFIG_FILE}" -r "${APP_WWW_ROOT}" init
  fi
  echo "starting..."
  "${APP_RUNTIME_ROOT}"/${APP_NAME}/filebrowser -c "${APP_CONFIG_FILE}"
}


start
