#!/usr/bin/env bash

# Helper script to start the service as the right user and config

# change to zookeeper dir
cd -P /opt/zookeeper

# make config
cat conf/zoo.cfg.base > conf/zoo.cfg


su zookeeper -c 'zkServer.sh start-foreground'