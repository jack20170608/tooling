#!/usr/bin/env bash

## Run this script with jack user, we don't want to install postgres with default root or postgres user

# Default to perform both download and installation
DO_CLEAN=false
DO_DOWNLOAD=false
DO_INSTALL=false

# Parse command line arguments
while getopts "cdi" opt; do
	case $opt in
	c) # Clean the download and install directory
		DO_CLEAN=true
		;;
	d) # Skip download step
		DO_DOWNLOAD=true
		;;
	i) # Skip installation step
		DO_INSTALL=true
		;;
	*) # Show help information
		echo "Usage: $0 [-c][-d] [-i]"
		echo "  -c: Clean the download and install directory"
		echo "  -d: Enable download"
		echo "  -i: Enable installation step"
		exit 1
		;;
	esac
done

version=8.1.4

## the original download address
#baseUrl="https://download.valkey.io/releases/valkey-8.1.4-noble-x86_64.tar.gz"
baseUrl="http://10.10.10.10/ilovemyhome/download/kv-db/valkey-8.1.4-noble-x86_64.tar.gz"

DOWNLOAD_HOME=/appvol/ilovemyhome/download/valkey
INSTALL_HOME=/appvol/ilovemyhome/install/valkey
DATA_HOME=/appvol/ilovemyhome/data/valkey
LOG_HOME=/appvol/ilovemyhome/logs/valkey
RUNTIME_DIR=/appvol/ilovemyhome/runtime/valkey
CONFIG_DIR=/appvol/ilovemyhome/config/valkey


# Clean the download and install directory
if [ "$DO_CLEAN" = true ]; then
	echo "Cleaning the download and install directory"
	rm -rf ${INSTALL_HOME}
fi

mkdir -pv ${DOWNLOAD_HOME} ${INSTALL_HOME} ${DATA_HOME} ${LOG_HOME} ${CONFIG_DIR}

cd ${DOWNLOAD_HOME} || exit 1

## Download
if [ "$DO_DOWNLOAD" = true ]; then
	echo "Downloading valkey-${version} ..."
	wget ${baseUrl}
else
	echo "Skipping download step";
fi

## Install
if [ "$DO_INSTALL" = true ]; then
	echo "Installing valkey-${version} ..."
	tar -zxvf valkey-${version}-noble-x86_64.tar.gz -C ${INSTALL_HOME}
	cd ${INSTALL_HOME} || exit 1
	mv valkey-${version}-noble-x86_64 valkey-${version}
	# Create a symbolic link
	rm -f ${RUNTIME_DIR} && ln -s ${INSTALL_HOME}/valkey-${version} ${RUNTIME_DIR}
else
	echo "Skipping installation step";
fi


## Set the environment variables
cat <<'EOF' > "/appvol/ilovemyhome/bin/set_valkey_envs.sh"
# user specific settings for valkey
export APP_NAME=valkey
export VALKEY_HOME=/appvol/ilovemyhome/runtime/${APP_NAME}
export VALKEY_BIN=${VALKEY_HOME}/bin

## The App data environment variables
export APP_HOME=${VALKEY_HOME}
export APP_CONFIG=/appvol/ilovemyhome/config/${APP_NAME}
export APP_DATA=/appvol/ilovemyhome/data/${APP_NAME}
export APP_LOG=/appvol/ilovemyhome/logs/${APP_NAME}

EOF

source /appvol/ilovemyhome/bin/set_valkey_envs.sh \
&& "$VALKEY_BIN"/valkey-cli --version
