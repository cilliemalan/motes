#!/bin/bash


cd /usr/local/etc/haproxy

WEB_HOSTS=$(host web | egrep -oe '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
CANARY_HOSTS=$(host web-canary | egrep -oe '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

printserver() {
    local name=$1
    local server=$2
    shift
    shift
    echo "    server $name $server:8080 $@"
}

printservers() {
    local name=$1
    local servers=$2
    local increment=0
    shift
    shift
    for s in $servers; do
        increment=$((increment+1))
        printserver "$name$increment" $s "$@"
    done
}

printweb() {
    printservers "web" "$WEB_HOSTS" weight 19 "$@"
}

printcanary() {
    printservers "canary" "$CANARY_HOSTS" weight 1 "$@"
}


export SERVERS=$(printweb; printcanary)

envsubst < haproxy.cfg.in > haproxy.cfg

kill -HUP 1

