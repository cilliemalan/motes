#!/bin/bash

HOST=eu.gcr.io
PROJECT=modern-kiln-165813
REPO=motes-kafka
VER=latest
TAG="$HOST/$PROJECT/$REPO:$VER"

docker build -t "$TAG" --cache-from "$TAG" .
