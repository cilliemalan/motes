#!/usr/bin/env bash

# Helper script to start the service as the right user and config

HOST=`hostname -s`
DOMAIN=`hostname -d`
ORD=
SERVICE=
if [[ "$HOST" =~ .*-([0-9]+)$ ]]; then
    ORD=${BASH_REMATCH[1]}
fi
if [[ "$DOMAIN" =~ ([a-zA-Z0-9-]+)\..*local ]]; then
    SERVICE=${BASH_REMATCH[1]}
fi

# wait 3 seconds. Should be enough for others server to come up
echo "Waiting 3 seconds..."
sleep 3
echo "Done waiting"


# print out some notes
if [[ -n "$SERVICE" ]]; then
    echo "Running in Kubernetes environment under service $SERVICE"
    echo "This is pod $HOST as $(hostname -f)"
    echo "Running as broker ID $ORD"
    echo "Other pods in this service:"
    kubectl get pods -o name -l "$(kubectl describe "svc/$SERVICE" | grep -Ei "Selector:" | sed "s/Selector:\s*//")"
else
    echo "Did not detect Kubernetes environment"
    echo "Running in standalone mode"
fi


# change to kafka dir
cd -P /opt/kafka


# set broker index
if [ -n "$ORD" ]; then
    echo "Setting broker index to $ORD"
    sed -i -e "s/broker.id=.*/broker.id=$ORD/" \
        /opt/kafka/config/server.properties
else
    echo "Setting broker index to 0"
    sed -i -e "s/broker.id=.*/broker.id=0/" \
        /opt/kafka/config/server.properties
fi


# re-own stuff (also for k8s screwups)
chown -R "kafka:kafka" /var/lib/kafka/ ./


#start kafka
echo "Starting kafka as user kafka"
su kafka -c 'bin/kafka-server-start.sh config/server.properties'


