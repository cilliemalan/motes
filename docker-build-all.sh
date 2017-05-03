#!/bin/bash

if [[ "$1" == "--fresh" ]]; then
    SCRIPT="./docker-build-fresh.sh"
else
    SCRIPT="./docker-build.sh"
fi

CWD=$(pwd)

time {
    cd "$CWD/kafka" && $SCRIPT
    cd "$CWD/redis" && $SCRIPT
    cd "$CWD/zookeeper" && $SCRIPT
    cd "$CWD/web" && $SCRIPT
}

cd "$CWD"