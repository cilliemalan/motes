#!/usr/bin/env bash

# Helper script to start the service as the right user and config


su zookeeper -c 'zkServer.sh start-foreground'