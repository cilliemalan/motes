#!/bin/bash

docker build -t cilliemalan/motes-zookeeper:latest --cache-from cilliemalan/motes-zookeeper:latest .
