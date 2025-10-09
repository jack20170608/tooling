#!/usr/bin/env bash

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
echo "Current Dir: [${SCRIPT_DIR}]"
APP_BIN_DIR="/appvol/ilovemyhome/bin"

source "${APP_BIN_DIR}"/set_valkey_envs.sh


# Configuration Parameters (Modify according to actual environment)
VALKEY_CONF="${APP_CONFIG}/valkey-prod.conf"
# shellcheck disable=SC2153
VALKEY_SERVER="${VALKEY_BIN}/valkey-server"
VALKEY_HOST="127.0.0.1"
VALKEY_PORT="6379"
VALKEY_CLI="${VALKEY_BIN}/valkey-cli"
USER=$(whoami)
VALKEY_PID=$(grep "pidfile" "${VALKEY_CONF}" | awk -F '"' '{print $2}')
VALKEY_PASSWORD=$(grep "requirepass" "$VALKEY_CONF" | awk '{print $2}')
LOG_DIR=$(grep "logfile" "$VALKEY_CONF" | awk -F '"' '{print $2}' | xargs dirname)
DATA_DIR=$(grep "dir" "$VALKEY_CONF" | awk '{print $2}')
SLAVE_HOST=

TEST_KEY="valkey_test_$(date +%s)"  # Unique test key to avoid conflicts

# Basic Function Test
basic_test() {
    echo "=== Basic Function Test ==="
    # 1. String Test
    echo "1. String Test: SET $TEST_KEY 'test_value'"
    $VALKEY_CLI -h $VALKEY_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD SET $TEST_KEY "test_value_$(date +%s)"
    if [ $? -ne 0 ]; then echo "String SET failed"; exit 1; fi

    echo "   String Test: GET $TEST_KEY"
    get_result=$($VALKEY_CLI -h $VALKEY_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD GET $TEST_KEY)
    if [ -z "$get_result" ]; then echo "String GET failed"; exit 1; fi
    echo "   Result: $get_result"

    # 2. Hash Test
    echo "2. Hash Test: HMSET user:test name 'test_user' age 25"
    $VALKEY_CLI -h $VALKEY_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD HMSET user:test name "test_user" age 25
    if [ $? -ne 0 ]; then echo "Hash HMSET failed"; exit 1; fi

    echo "   Hash Test: HGETALL user:test"
    $VALKEY_CLI -h $VALKEY_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD HGETALL user:test
    if [ $? -ne 0 ]; then echo "Hash HGETALL failed"; exit 1; fi

    # 3. List Test
    echo "3. List Test: LPUSH mylist 'a' 'b' 'c'"
    $VALKEY_CLI -h $VALKEY_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD LPUSH mylist "a" "b" "c"
    if [ $? -ne 0 ]; then echo "List LPUSH failed"; exit 1; fi

    echo "   List Test: LRANGE mylist 0 -1"
    $VALKEY_CLI -h $VALKEY_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD LRANGE mylist 0 -1
    if [ $? -ne 0 ]; then echo "List LRANGE failed"; exit 1; fi

    echo "=== Basic Function Test Passed ==="
    echo ""
}

# Persistence Test
persistence_test() {
    echo "=== Persistence Test ==="
    # 1. Set test key first
    echo "1. Set persistence test key: SET ${TEST_KEY}_persist 'persist_value'"
    $VALKEY_CLI -h $VALKEY_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD SET "${TEST_KEY}_persist" "persist_value"
    if [ $? -ne 0 ]; then echo "Persistence test key SET failed"; exit 1; fi

    # 2. Restart Valkey service
    echo "2. Restart Valkey service (to verify persistence)"
    ${APP_BIN_DIR}/app_valkey.sh restart
    sleep 5  # Wait for service to start

    # 3. Check if test key exists
    echo "3. Check persistence test key: GET ${TEST_KEY}_persist"
    persist_result=$($VALKEY_CLI -h $VALKEY_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD GET "${TEST_KEY}_persist")
    if [ -z "$persist_result" ]; then
        echo "Persistence Test Failed: Data lost after restart"; exit 1;
    else
        echo "   Result: $persist_result"
        echo "=== Persistence Test Passed ==="
    fi
    echo ""
}

# Performance Test
performance_test() {
    echo "=== Performance Test (100 Concurrent, 100,000 Requests) ==="
    echo "Test Command: valkey-benchmark -c 100 -n 100000 -t set,get"
    $VALKEY_CLI -h $VALKEY_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD ping > /dev/null  # Check connection first
    if [ $? -ne 0 ]; then echo "Valkey service not ready, performance test skipped"; return; fi

    valkey-benchmark -h $VALKEY_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD -c 100 -n 100000 -t set,get | grep -E "Requests per second|Average latency"
    echo "=== Performance Test Completed ==="
    echo ""
}

# Master-Slave Replication Test (Requires Master-Slave Architecture)
replica_test() {
    if [ -z "$SLAVE_HOST" ]; then echo "Slave node IP not configured, master-slave replication test skipped"; return; fi
    echo "=== Master-Slave Replication Test ==="
    # 1. Set test key on master node
    echo "1. Set replication test key on master node: SET ${TEST_KEY}_replica 'replica_value'"
    $VALKEY_CLI -h $VALKEY_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD SET "${TEST_KEY}_replica" "replica_value"
    if [ $? -ne 0 ]; then echo "Master node SET failed"; exit 1; fi

    # 2. Check test key on slave node
    echo "2. Check replication test key on slave node: GET ${TEST_KEY}_replica"
    replica_result=$($VALKEY_CLI -h $SLAVE_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD GET "${TEST_KEY}_replica")
    if [ -z "$replica_result" ]; then
        echo "Master-Slave Replication Test Failed: Slave node failed to synchronize data"; exit 1;
    else
        echo "   Result: $replica_result"
        echo "=== Master-Slave Replication Test Passed ==="
    fi
    echo ""
}

# Clean Up Test Data
cleanup() {
    echo "=== Clean Up Test Data ==="
    $VALKEY_CLI -h $VALKEY_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD DEL $TEST_KEY "${TEST_KEY}_persist" "${TEST_KEY}_replica" mylist user:test
    if [ $? -eq 0 ]; then echo "Test data cleaned up successfully"; else echo "Test data cleanup failed"; fi
    # Clean up on slave node (if configured)
    if [ -n "$SLAVE_HOST" ]; then
        $VALKEY_CLI -h $SLAVE_HOST -p $VALKEY_PORT -a $VALKEY_PASSWORD DEL $TEST_KEY "${TEST_KEY}_persist" "${TEST_KEY}_replica" mylist user:test
    fi
}

# Execute Tests
basic_test
persistence_test
performance_test
replica_test
cleanup

echo ""
echo "=== All Tests Completed ==="
