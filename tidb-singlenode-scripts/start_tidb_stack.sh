#!/bin/bash -e

echo "Starting Placement Driver..."
pd-server \
    --data-dir="$PD_DATA_DIR"

echo "Starting TiKV..."
tikv-server \
    --pd="127.0.0.1:$PD_PORT" \
    --data-dir="$TIKV_DATA_DIR"

echo "Starting TiDB..."
tidb-server \
    --path="127.0.0.1:$PD_PORT"

while { grep -c pd-server /proc/*/cmdline \
     && grep -c tikv-server /proc/*/cmdline \
     && grep -c tidb-server /proc/*/cmdline }; do
    sleep 1
done
exit 1
