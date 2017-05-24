#!/bin/bash

# this script will deploy the ecosystem to a kubernetes cluster. It will use the k8s
# cluster as specified by the command line parameter (dev, test, or prod). If
# not specified it will use minikube.


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"



LABEL=$1

# check that the specified cluster exists
if [[ -n "$LABEL" ]]; then

    if [[ -n "$ZONE" ]]; then
        ZONEPARM="--zone $ZONE"
    fi

    CLUSTER_NAME="$LABEL-cluster"

    if [[ -z "$(gcloud container clusters list --project "$PROJECT_ID" $ZONEPARM | grep "$LABEL-cluster.*RUNNING")" ]]
    then
        echo "The cluster $CLUSTER_NAME does not exist or is not running. All clusters:"
        echo gcloud container clusters list --project "$PROJECT_ID" $ZONEPARM
        gcloud container clusters list --project "$PROJECT_ID" $ZONEPARM
        exit 1
    fi

else
fi

# get creds and configure kubectl
build-scripts/utilities/use-cluster.sh $LABEL


# deploy to the cluster
build-scripts/utilities/manage-deployments.sh -v "latest"
