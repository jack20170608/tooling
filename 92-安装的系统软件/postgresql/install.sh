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
		echo "  -d: Skip download step"
		echo "  -i: Skip installation step"
		exit 1
		;;
	esac
done

version=18
baseUrl="https://download.postgresql.org/pub/repos/yum/18/redhat/rhel-10-x86_64/"

sudo mkdir -pv /appvol/ilovemyhome/{bin,config,libs,data,install,logs,runtime,tmp,download} &&
	sudo chown -R jack:jack /appvol/ilovemyhome &&
	cd /appvol/ilovemyhome/download/ &&
	mkdir -pv /appvol/ilovemyhome/download/postgresql-${version}

DOWNLOAD_HOME=/appvol/ilovemyhome/download/postgresql-${version}
INSTALL_HOME=/appvol/ilovemyhome/install/postgresql-${version}
RUNTIME_DIR=/appvol/ilovemyhome/runtime/postgresql-${version}
DATA_HOME=/appvol/ilovemyhome/data/postgresql-${version}
LOG_HOME=/appvol/ilovemyhome/logs/postgresql-${version}


# Clean the download and install directory
if [ "$DO_CLEAN" = true ]; then
	echo "Cleaning the download and install directory"
	rm -rf ${INSTALL_HOME}
fi

mkdir -pv ${DOWNLOAD_HOME}
mkdir -pv ${INSTALL_HOME}
mkdir -pv ${DATA_HOME}
mkdir -pv ${LOG_HOME}

RPM_LIBS=(
	"postgresql18-libs-18.0-1PGDG.rhel10.x86_64.rpm"
  "postgresql18-18.0-1PGDG.rhel10.x86_64.rpm"
	"postgresql18-contrib-18.0-1PGDG.rhel10.x86_64.rpm"
	"postgresql18-devel-18.0-1PGDG.rhel10.x86_64.rpm"
	"postgresql18-server-18.0-1PGDG.rhel10.x86_64.rpm"
)

function downloadRpm() {
	local rpmName=$1
	local rpmUrl=$2
	local rpmPath=$3
	if [ ! -f "${rpmPath}/${rpmName}" ]; then
		echo "Downloading ${rpmName} from ${rpmUrl}"
		curl -L -o "${rpmPath}/${rpmName}" "${rpmUrl}"
	fi
}

# Determine whether to perform download based on DO_DOWNLOAD flag
if [ "$DO_DOWNLOAD" = true ]; then
	for rpm in "${RPM_LIBS[@]}"; do
		downloadRpm "${rpm}" "${baseUrl}${rpm}" "${DOWNLOAD_HOME}"
	done
else
	echo "Skipping download step"
fi

# Determine whether to perform installation based on DO_INSTALL flag
if [ "$DO_INSTALL" = true ]; then
	for rpm in "${RPM_LIBS[@]}"; do
		echo "Installing ${rpm}"
		rpm2cpio "${DOWNLOAD_HOME}/${rpm}" | cpio -idmv -D "${INSTALL_HOME}"
	done
else
	echo "Skipping installation step"
fi

## Remove the symbol link and recreate
rm -rf ${RUNTIME_DIR} &&
	ln -s ${INSTALL_HOME} ${RUNTIME_DIR}

## Set the environment variables
cat <<'EOF' > "/appvol/ilovemyhome/bin/set_pg_envs.sh"
# user specific settings for postgresql

export PG_MAIN_VERSION=18
export PG_HOME=/appvol/ilovemyhome/runtime/postgresql-${PG_MAIN_VERSION}
export PG_LIB=${PG_HOME}/usr/pgsql-${PG_MAIN_VERSION}/lib:${PG_HOME}/usr/lib
export LD_LIBRARY_PATH=${PG_LIB}:$LD_LIBRARY_PATH
export PG_BIN=${PG_HOME}/usr/pgsql-${PG_MAIN_VERSION}/bin

## The App data environment variables
export APP_NAME=postgresql
export APP_HOME=${PG_HOME}
export APP_DATA=/appvol/ilovemyhome/data/${APP_NAME}/DB
export APP_LOG=/appvol/ilovemyhome/log/${APP_NAME}-${PG_MAIN_VERSION}

export PGDATA=${APP_DATA}

EOF

source /appvol/ilovemyhome/bin/set_pg_envs.sh \
&& "$PG_BIN"/psql --version
