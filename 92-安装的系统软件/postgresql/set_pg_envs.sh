# user specific settings for postgresql

export PG_MAIN_VERSION=18
export PG_HOME=/appvol/ilovemyhome/runtime/postgresql-${PG_MAIN_VERSION}
export PG_LIB=${PG_HOME}/usr/pgsql-${PG_MAIN_VERSION}/lib:${PG_HOME}/usr/lib
export PG_BIN_DIR=${PG_HOME}/usr/pgsql-${PG_MAIN_VERSION}/bin
export LD_LIBRARY_PATH=${PG_LIB}:$LD_LIBRARY_PATH
