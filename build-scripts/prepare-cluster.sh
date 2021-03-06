#!/bin/bash

# this script prepares a cluster passed as the first parameter
# possible options include: local, dev, test, prod
LABEL=$1

# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


if [[ -z "$LABEL" ]]; then
    if [[ $(minikube status --format "{{.MinikubeStatus}} {{.LocalkubeStatus}}") != "Running Running" ]]; then
        echo "Preparing minikube"
        minikube start
        if [[ $? != 0 ]]; then
            echo "Failed to start minikube";
            exit 1;
        else
            echo "Minikube started";
        fi
    else
            echo "Minikube running";
    fi
else

    if [[ -n "$ZONE" ]]; then
        ZONEPARM="--zone $ZONE"
    fi

    NODES=0
    NODE_TYPE="n1-standard-1"
    CLUSTER_NAME="$LABEL-cluster"
    if [[ "$LABEL" == "dev" ]]; then
        NODES=1
        NODE_TYPE="n1-standard-1"
    elif [[ "$LABEL" == "test" ]]; then
        NODES=1
        NODE_TYPE="n1-standard-2"
    elif [[ "$LABEL" == "prod" ]]; then
        NODES=3
        NODE_TYPE="n1-standard-2"
    else
        echo "Unknown environment name $LABEL. must be dev, test, or prod."
        exit 2;
    fi

    echo "Preparing $LABEL cluster"


    if [[ -z "$(gcloud container clusters list --project "$PROJECT_ID" $ZONEPARM | grep "$LABEL-cluster")" ]]
    then
        echo "Creating $LABEL-cluster in ${ZONE:-the default zone}"

        gcloud container --project "$PROJECT_ID" clusters create "$CLUSTER_NAME" $ZONEPARM \
            --cluster-version=1.6.2 \
            --machine-type "$NODE_TYPE" --image-type "COS" --disk-size "100" \
            --scopes "https://www.googleapis.com/auth/compute","https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
            --num-nodes "$NODES" --network "default" --enable-cloud-logging --no-enable-cloud-monitoring

    else
        echo "$LABEL-cluster exists"
    fi

fi

