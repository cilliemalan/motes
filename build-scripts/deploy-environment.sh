#!/bin/bash

# this script will update the environment specified as an argument by 
# configuring kubectl and deploying the current hash of images


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"



LABEL=$1

if [[ -z "$LABEL" ]]; then
    echo "Must specify environment name (dev, test, or prod)"
    exit 1;
fi

if [[ -n "$ZONE" ]]; then
    ZONEPARM="--zone '$ZONE'"
fi

CLUSTER_NAME="$LABEL-cluster"

if [[ -z "$(gcloud container clusters list --project "$PROJECT_ID" $ZONEPARM | grep "$LABEL-cluster.*RUNNING")" ]]
then
    echo "The cluster $CLUSTER_NAME does not exist or is not running. All clusters:"
    echo gcloud container clusters list --project "$PROJECT_ID" $ZONEPARM
    gcloud container clusters list --project "$PROJECT_ID" $ZONEPARM
    exit 1
fi

# get creds
build-scripts/utilities/use-environment.sh $LABEL


# deploy
build-scripts/update-deployment.sh $LABEL
