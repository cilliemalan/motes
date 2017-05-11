#!/bin/bash

# this script uses a specified gke environment cluster


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
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

# get creds
gcloud container clusters get-credentials "$CLUSTER_NAME" $ZONEPARM