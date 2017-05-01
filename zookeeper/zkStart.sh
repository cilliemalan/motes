#!/usr/bin/env bash

# Helper script to start the service as the right user and config

HOST=`hostname -s`
DOMAIN=`hostname -d`

# wait 3 seconds. Should be enough for others server to come up
echo "Waiting 3 seconds..."
sleep 3
echo "Done waiting"

function get_my_id() {
    if [[ "$HOST" =~ .*-([0-9]+)$ ]]; then
        local ord=${BASH_REMATCH[1]}
        echo "$((ord+1))"
    fi
}

function get_servers() {
    local domain=$(hostname -d)
    local selector=$(kubectl describe svc/zookeeper | grep -Ei "Selector:" | sed "s/Selector:\s*//")
    local pods=$(kubectl get pods -l "$selector" -o name | sed -r "s/pods\/(.+)/\1.$domain/")
    for pod in $pods
    do
        [[ "$pod" =~ .*-([0-9]+) ]]
        local ord=${BASH_REMATCH[1]}
        local num=$((ord+1))
        echo "server.$num=$pod:2888:3888"
    done
}


# change to zookeeper dir
cd -P /opt/zookeeper

# make config
cat conf/zoo.cfg.base > conf/zoo.cfg
echo "" >> conf/zoo.cfg
get_servers >> conf/zoo.cfg

# create data dir if needed
if [ ! -e /var/lib/zookeeper/data ]; then
    mkdir /var/lib/zookeeper/data
fi

# set my id
MY_ID=$(get_my_id)
if [ -n $MY_ID ]; then
    echo $MY_ID > /var/lib/zookeeper/data/myid
fi

# re-own stuff (also for k8s screwups)
chown -R "zookeeper:zookeeper" /var/lib/zookeeper/ conf/


#change
su zookeeper -c 'zkServer.sh start-foreground'


