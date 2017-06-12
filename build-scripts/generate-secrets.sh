#!/bin/bash

# Generates secrets if needed for a specified k8s cluster.


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


build-scripts/utilities/use-cluster.sh $1


# Generates 32 byte password
generatepassword() {
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
}


savepasswords() {
    local mariadb=$(generatepassword)
    local mariadb_root=$(generatepassword)
    local redis=$(generatepassword)
    local zookeeper=$(generatepassword)
    local grafana=$(generatepassword)
    local influxdb1=$(generatepassword)
    local influxdb2=$(generatepassword)

    # MariaDb
    kubectl create secret generic mariadb \
        "--from-literal=password=$mariadb" \
        "--from-literal=root_password=$mariadb_root"

    # Redis
    kubectl create secret generic redis \
        "--from-literal=password=$redis"

    # Grafana
    kubectl create secret generic grafana \
        "--from-literal=password=$grafana"

    # Zookeeper
    kubectl create secret generic zookeeper \
        "--from-literal=password=$zookeeper"

    # InfluxDb
    kubectl create secret generic influxdb \
        "--from-literal=adminusername=admin" \
        "--from-literal=adminpassword=$influxdb1" \
        "--from-literal=username=influx" \
        "--from-literal=password=$influxdb2"
}

# generate passwords and store in k8s
savepasswords
