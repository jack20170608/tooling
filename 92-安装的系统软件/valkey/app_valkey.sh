#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "Current Dir: [${SCRIPT_DIR}]"
APP_BIN_DIR="/appvol/ilovemyhome/bin"

source "${APP_BIN_DIR}"/set_valkey_envs.sh

if [ "$APP_NAME" = "" ]; then
	echo -e "\033[0;31m Not find APP NAME \033[0m"
	exit 1
fi
if [ "$APP_HOME" = "" ]; then
	echo -e "\033[0;31m Not find APP HOME \033[0m"
	exit 1
fi
if [ "$APP_DATA" = "" ]; then
	echo -e "\033[0;31m Not find APP DATA \033[0m"
	exit 1
fi
if [ "$APP_LOG" = "" ]; then
	echo -e "\033[0;31m Not find APP LOG \033[0m"
	exit 1
fi

OPS=$1
if [ "$OPS" = "" ]; then
	echo -e "\033[0;31m Not find operation type. \033[0m  \033[0;34m {start|stop|restart|status} \033[0m"
	exit 1
fi

# Configuration Parameters (Modify according to actual environment)
VALKEY_CONF="${APP_CONFIG}/valkey-prod.conf"
# shellcheck disable=SC2153
VALKEY_SERVER="${VALKEY_BIN}/valkey-server"
VALKEY_CLI="${VALKEY_BIN}/valkey-cli"
USER=$(whoami)
VALKEY_PID=$(grep "pidfile" "${VALKEY_CONF}" | awk -F '"' '{print $2}')
VALKEY_PASSWORD=$(grep "requirepass" "$VALKEY_CONF" | awk '{print $2}')
LOG_DIR=$(grep "logfile" "$VALKEY_CONF" | awk -F '"' '{print $2}' | xargs dirname)
DATA_DIR=$(grep "dir" "$VALKEY_CONF" | awk '{print $2}')

# Log Rotation (Retain logs for the last 7 days, execute at 00:00 every day, can be added to crontab)
log_rotate() {
	# shellcheck disable=SC2155
	local log_file=$(grep "logfile" "$VALKEY_CONF" | awk -F '"' '{print $2}')
	# shellcheck disable=SC2155
	local rotate_log="${log_file}.$(date +%Y%m%d)"
	# shellcheck disable=SC2046
	if [ -f "$log_file" ] && [ $(du -m "$log_file" | awk '{print $1}') -ge 100 ]; then # Rotate when log exceeds 100MB
		echo "Rotating log: $log_file -> $rotate_log"
		mv "$log_file" "$rotate_log"
		gzip "$rotate_log" # Compress old log
		# Stop and restart the service (to make new log take effect)
		$0 stop
		$0 start
		# Delete logs older than 7 days
		find $(dirname "$log_file") -name "valkey-6379.log.*.gz" -mtime +7 -delete
	fi
}

# Start Service
start() {
	if [ -f "$VALKEY_PID" ] && ps -p $(cat "$VALKEY_PID") >/dev/null; then
		echo "Valkey is already running (PID: $(cat "$VALKEY_PID"))"
		exit 0
	fi

	log_rotate # Check if log rotation is needed before startup
	echo "Starting Valkey (Configuration File: $VALKEY_CONF)"
	$VALKEY_SERVER $VALKEY_CONF
	sleep 3
	if [ -f $VALKEY_PID ] && ps -p $(cat "$VALKEY_PID") >/dev/null; then
		echo "Valkey started successfully (PID: $(cat $VALKEY_PID))"
	else
		echo "Valkey startup failed, check log: $LOG_DIR/valkey-6379.log"
		exit 1
	fi
}

# Stop Service
stop() {
    # 检查 PID 文件是否存在
    if [ ! -f "$VALKEY_PID" ]; then
        echo "Valkey is not running (PID file not found)"
        return 0
    fi

    # 读取并验证 PID
    pid=$(cat "$VALKEY_PID")
    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        echo "Invalid PID in file: $VALKEY_PID"
        rm -f "$VALKEY_PID"
        return 1
    fi

    # 检查进程是否真的在运行
    if ! ps -p "$pid" >/dev/null; then
        echo "Valkey is not running (PID $pid not found)"
        rm -f "$VALKEY_PID"
        return 0
    fi

    echo "Stopping Valkey (PID: $pid)"

    # 尝试优雅关闭 (避免密码暴露在命令行)
    if [ -n "$VALKEY_CLI" ] && [ -x "$VALKEY_CLI" ]; then
        # 使用密码文件或环境变量更安全
        if [ -n "$VALKEY_PASSWORD" ]; then
            echo "$VALKEY_PASSWORD" | "$VALKEY_CLI" -h 127.0.0.1 -p 6379 -a "$VALKEY_PASSWORD" shutdown >/dev/null 2>&1
        else
            "$VALKEY_CLI" -h 127.0.0.1 -p 6379 shutdown >/dev/null 2>&1
        fi
    else
        # 没有 valkey-cli，尝试直接发送 SIGTERM
        kill "$pid" >/dev/null 2>&1
    fi

    # 等待进程终止
    for _ in {1..10}; do
        if ! ps -p "$pid" >/dev/null; then
            break
        fi
        sleep 1
    done

    # 检查是否需要强制终止
    if ps -p "$pid" >/dev/null; then
        echo "Force stopping Valkey (PID: $pid)"
        kill -9 "$pid" >/dev/null 2>&1
        sleep 1
    fi

    # 清理 PID 文件
    rm -f "$VALKEY_PID"
    echo "Valkey stopped successfully"
    return 0
}

# Restart Service
restart() {
	stop
	start
}

# Check Status
status() {
	if [ -f $VALKEY_PID ] && ps -p $(cat $VALKEY_PID) >/dev/null; then
		echo "Valkey is running (PID: $(cat $VALKEY_PID))"
		# Output basic service information
		$VALKEY_CLI -h 127.0.0.1 -p 6379 -a $VALKEY_PASSWORD info server | grep -E "redis_version|redis_git_sha1|process_id|uptime_in_seconds"
	else
		echo "Valkey is not running"
	fi
}

# Command Distribution
case $1 in
start)
	start
	;;
stop)
	stop
	;;
restart)
	restart
	;;
status)
	status
	;;
log-rotate)
	log_rotate
	;;
*)
	echo "Usage: $0 {start|stop|restart|status|log-rotate}"
	exit 1
	;;
esac
