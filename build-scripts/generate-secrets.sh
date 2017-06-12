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
    local redis=$(generatepassword)
    local mongo1=$(generatepassword)
    local mongo2=$(generatepassword)
    local zookeeper=$(generatepassword)
    local grafana=$(generatepassword)
    local influxdb1=$(generatepassword)
    local influxdb2=$(generatepassword)

    # Redis
    kubectl create secret generic redis \
        "--from-literal=password=$redis"

    # Mongo
    kubectl create secret generic mongo \
        "--from-literal=rootuser=admin" \
        "--from-literal=rootpassword=@mongo1" \
        "--from-literal=user=mongo" \
        "--from-literal=password=@mongo2" \

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
