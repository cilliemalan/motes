#!/bin/bash

# this script uses a specified gke environment cluster


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"



LABEL=${1:-local}

if [[ "$LABEL" == "local" ]]; then
    # use minikube
    kubectl config set-context minikube

    if [[ $? != 0 ]]; then
        echo "Failed to switch to minikube";
        exit 1;
    fi
else

    if [[ -n "$ZONE" ]]; then
        ZONEPARM="--zone $ZONE"
    fi

    # get creds
    CLUSTER_NAME="$LABEL-cluster"
    gcloud container clusters get-credentials "$CLUSTER_NAME" $ZONEPARM
    
    if [[ $? != 0 ]]; then
        echo "Failed to switch to $LABEL cluster";
        exit 1;
    fi
fi
