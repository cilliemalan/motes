#!/bin/bash


cd /usr/local/etc/haproxy

WEB_HOSTS=$(host web | egrep -oe '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
CANARY_HOSTS=$(host web-canary | egrep -oe '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')


printserver() {
    local server=$1
    shift
    echo "    server public $server:8080 $@"
}

printservers() {
    local servers=$1
    shift
    for s in $servers; do
        printserver $s "$@"
    done
}

printweb() {
    printservers "$WEB_HOSTS" weight 95 "$@"
}

printcanary() {
    printservers "$CANARY_HOSTS" weight 5 "$@"
}


export SERVERS=$(printweb; printcanary)

envsubst < haproxy.cfg.in > haproxy.cfg

kill -HUP 1

