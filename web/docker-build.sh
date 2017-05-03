#!/bin/bash

HOST=eu.gcr.io
PROJECT=dust-motes
REPO=motes-web
VER=latest
TAG="$HOST/$PROJECT/$REPO:$VER"

docker build -t "$TAG" --cache-from "$TAG" .