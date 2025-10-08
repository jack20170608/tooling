#!/usr/bin/env bash

## Run this scripts with jack user, we don't want to install the postgres with default root or postgres

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

mkdir -pv ${DOWNLOAD_HOME}
mkdir -pv ${INSTALL_HOME}

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


#for rpm in "${RPM_LIBS[@]}"; do
#    downloadRpm "${rpm}" "${baseUrl}${rpm}" "${DOWNLOAD_HOME}"
#done

for rpm in "${RPM_LIBS[@]}"; do
    rpm2cpio "${DOWNLOAD_HOME}/${rpm}" | cpio -idmv -D "${INSTALL_HOME}"
done
