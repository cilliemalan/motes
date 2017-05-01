#!/usr/bin/env bash

# Helper script to start the service as the right user and config

HOST=`hostname -s`
DOMAIN=`hostname -d`
ORD=
MY_ID=
SERVICE=
if [[ "$HOST" =~ .*-([0-9]+)$ ]]; then
    ORD=${BASH_REMATCH[1]}
    if [[ -n "$ORD" ]]; then
        MY_ID=$((ORD+1))
    fi
fi
if [[ "$DOMAIN" =~ ([a-zA-Z0-9-]+)\..*local ]]; then
    SERVICE=${BASH_REMATCH[1]}
fi

# wait 3 seconds. Should be enough for others server to come up
echo "Waiting 3 seconds..."
sleep 3
echo "Done waiting"

# spits out servers based on pods in current service
# will probably fail if using weird selectors
function get_servers() {
    local selector=$(kubectl describe "svc/$SERVICE" | grep -Ei "Selector:" | sed "s/Selector:\s*//")
    if [ -n "$selector" ]; then
        local pods=$(kubectl get pods -l "$selector" -o name | sed -r "s/pods\/(.+)/\1.$DOMAIN/")
        for pod in $pods
        do
            [[ "$pod" =~ .*-([0-9]+) ]]
            local ord=${BASH_REMATCH[1]}
            local num=$((ord+1))
            echo "server.$num=$pod:2888:3888"
        done
    fi
}

# print out some notes
if [[ -n "$SERVICE" ]]; then
    echo "Running in Kubernetes environment under service $SERVICE"
    echo "This is pod $HOST as $(hostname -f)"
    echo "Running as server ID $MY_ID"
    echo "Other pods in this service:"
    kubectl get pods -o name -l "$(kubectl describe "svc/$SERVICE" | grep -Ei "Selector:" | sed "s/Selector:\s*//")"
else
    echo "Did not detect Kubernetes environment"
    echo "Running in standalone mode"
fi


# change to zookeeper dir
cd -P /opt/zookeeper

# make config
cat conf/zoo.cfg.base > conf/zoo.cfg
echo >> conf/zoo.cfg
get_servers >> conf/zoo.cfg
echo >> conf/zoo.cfg
echo "Using zookeeper configuration:"
echo
cat conf/zoo.cfg
echo && echo



# create data dir if needed
ZK_DATADIR="/var/lib/zookeeper/data"
if [ ! -e "$ZK_DATADIR" ]; then
    echo "creating $ZK_DATADIR"
    mkdir "$ZK_DATADIR"
fi


# set my id
if [ -n $MY_ID ]; then
    echo "Setting server ID to $MY_ID"
    echo $MY_ID > /var/lib/zookeeper/data/myid
fi


# re-own stuff (also for k8s screwups)
chown -R "zookeeper:zookeeper" /var/lib/zookeeper/ conf/


#change
echo "Starting zookeeper as user zookeeper"
su zookeeper -c 'zkServer.sh start-foreground'


