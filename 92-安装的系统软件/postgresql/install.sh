#!/usr/bin/env bash

## Run this script with jack user, we don't want to install postgres with default root or postgres user

# Default to perform both download and installation
DO_DOWNLOAD=true
DO_INSTALL=true

# Parse command line arguments
while getopts "di" opt; do
  case $opt in
    d) # Skip download step
      DO_DOWNLOAD=false
      ;;
    i) # Skip installation step
      DO_INSTALL=false
      ;;
    *) # Show help information
      echo "Usage: $0 [-d] [-i]"
      echo "  -d: Skip download step"
      echo "  -i: Skip installation step"
      exit 1
      ;;
  esac
done

version=18
baseUrl="https://download.postgresql.org/pub/repos/yum/18/redhat/rhel-10-x86_64/"
#baseUrl="https://get.enterprisedb.com/postgresql/"
commonBaseUrl="https://download.postgresql.org/pub/repos/yum/common/redhat/rhel-10-x86_64/"

sudo mkdir -pv /appvol/ilovemyhome/{bin,config,libs,data,install,logs,runtime,tmp,download} \
&& sudo chown -R jack:jack /appvol/ilovemyhome \
&& cd /appvol/ilovemyhome/download/ \
&& mkdir -pv /appvol/ilovemyhome/download/postgresql-${version}

DOWNLOAD_HOME=/appvol/ilovemyhome/download/postgresql-${version}
INSTALL_HOME=/appvol/ilovemyhome/install/postgresql-${version}
RUNTIME_DIR=/appvol/ilovemyhome/runtime/postgresql-${version}

mkdir -pv ${DOWNLOAD_HOME}
mkdir -pv ${INSTALL_HOME}
mkdir -pv ${RUNTIME_DIR}


RPM_LIBS=(
    "postgresql18-libs-18.0-1PGDG.rhel10.x86_64.rpm"
    "postgresql18-server-18.0-1PGDG.rhel10.x86_64.rpm"
    "postgresql18-devel-18.0-1PGDG.rhel10.x86_64.rpm"
    "postgresql18-contrib-18.0-1PGDG.rhel10.x86_64.rpm"
    "postgresql18-client-18.0-1PGDG.rhel10.x86_64.rpm"
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
        rpm2cpio "${DOWNLOAD_HOME}/${rpm}" | cpio -idmv -D "${INSTALL_HOME}"
    done
else
    echo "Skipping installation step"
fi

## Remove the symbol link and recreate
rm -f ${RUNTIME_DIR} \
&& ln -s ${INSTALL_HOME} ${RUNTIME_DIR}

