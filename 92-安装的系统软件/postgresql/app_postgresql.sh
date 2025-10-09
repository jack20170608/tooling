#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
echo "Current Dir: [${SCRIPT_DIR}]"
APP_BIN_DIR="/appvol/ilovemyhome/bin"

source "${APP_BIN_DIR}"/set_pg_envs.sh

if [ "$APP_NAME" = "" ];
then
    echo -e "\033[0;31m Not find APP NAME \033[0m"
    exit 1
fi
if [ "$APP_HOME" = "" ];
then
    echo -e "\033[0;31m Not find APP HOME \033[0m"
    exit 1
fi
if [ "$APP_DATA" = "" ];
then
    echo -e "\033[0;31m Not find APP DATA \033[0m"
    exit 1
fi
if [ "$APP_LOG" = "" ];
then
    echo -e "\033[0;31m Not find APP LOG \033[0m"
    exit 1
fi

OPS=$1
if [ "$OPS" = "" ];
then
    echo -e "\033[0;31m Not find operation type. \033[0m  \033[0;34m {start|stop|restart|status} \033[0m"
    exit 1
fi

echo "............................."
echo "PG_BIN is $PG_BIN"
echo "PGDATA is $PGDATA"
echo "APP_LOG is $APP_LOG"
echo "............................."

mkdir -pv "$APP_DATA" "$APP_LOG" "$PGDATA"


function start()
{
  PID=$(pgrep -fa "$APP_NAME" | grep -Ev "app_postgresql.sh|tail|grep" | cut -d ' ' -f1 )
	if [ x"$PID" != x"" ]; then
	    echo "$APP_NAME is running..."
	else
		"${PG_BIN}"/pg_ctl start
		echo "Start $APP_NAME successfully..."
	fi
}

function stop()
{
  echo "Stop $APP_NAME"
  PID=$(pgrep -fa "$APP_NAME" | grep -Ev "app_postgresql|tail|grep" | cut -d ' ' -f1 )
	if [ x"$PID" != x"" ]; then
	  "${PG_BIN}"/pg_ctl stop
		echo "$APP_NAME (pid:$PID) exiting..."
		while [ x"$PID" != x"" ]
		do
			sleep 1
     PID=$(pgrep -fa "$APP_NAME" | grep -Ev "app_postgresql.sh|tail|grep" | cut -d ' ' -f1 )
		done
		echo "$APP_NAME stop successfully..."
	else
		echo "$APP_NAME stopping in progress..."
	fi
}

function restart()
{
    stop
    sleep 2
    start
}

function status()
{
  # shellcheck disable=SC2126
   PID=$(pgrep -fa "$APP_NAME" | grep -Ev "app_postgresql.sh|tail|grep" | wc -l )
    if [ $PID != 0 ];then
        echo "$APP_NAME is running..."
    else
        echo "$APP_NAME already stopped..."
    fi
}

case $1 in
    start)
    start;;
    stop)
    stop;;
    restart)
    restart;;
    status)
    status;;
    *)

esac
