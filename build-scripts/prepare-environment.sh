#!/bin/bash

# this script prepares an environment passed as the first parameter
# possible options include: local, dev, test, prod
LABEL=$1

if [[ -z "$LABEL" ]]; then
    echo "Must specify environment name (dev, test, or prod)"
    exit 1;
fi

# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


if [[ -n "$ZONE" ]]; then
    ZONEPARM="--zone $ZONE"
fi


NODES=0
NODE_TYPE="n1-standard-1"
CLUSTER_NAME="$LABEL-cluster"
if [[ "$LABEL" == "dev" ]]; then
    NODES=5
    NODE_TYPE="n1-standard-2"
elif [[ "$LABEL" == "test" ]]; then
    NODES=5
    NODE_TYPE="n1-standard-2"
elif [[ "$LABEL" == "prod" ]]; then
    NODES=10
    NODE_TYPE="n1-standard-4"
else
    echo "Unknown environment name $LABEL. must be dev, test, or prod."
    exit 2;
fi


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
