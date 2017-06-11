#!/bin/sh

CONFIG=${1:-/usr/local/etc/redis/redis.conf}

if [[ -n "$PASSWORD" ]]; then
    echo "Configuring password..."
    echo "requirepass $PASSWORD" >> $CONFIG
    export PASSWORD=
fi

echo "Starting   redis-server $CONFIG"
redis-server $CONFIG
