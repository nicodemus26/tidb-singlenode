#!/bin/bash -e

echo "Starting Placement Driver..."
pd-server \
    --data-dir="$PD_DATA_DIR" &

sleep 3

echo "Starting TiKV..."
tikv-server \
    --pd="127.0.0.1:2379" \
    --data-dir="$TIKV_DATA_DIR" &

sleep 3

echo "Starting TiDB..."
tidb-server \
    --path="127.0.0.1:2379" &

while grep '^'pd-server /proc/*/cmdline >/dev/null \
    && grep '^'tikv-server /proc/*/cmdline >/dev/null \
    && grep '^'tidb-server /proc/*/cmdline >/dev/null
do
    sleep 1
done
exit 1
