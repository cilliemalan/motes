#!/bin/bash

# Creates a single deployment from an argument specified as <set>/<deployment>. The rest
# of the args are passed to kubectl apply

# E.g.  create-deployment.sh ecosystem/redis


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


DEPLOYMENTFILE="$DIR/deployments/$1.yaml"
shift


# sub environment into the deployment file and pass to kubectl
build-scripts/utilities/envsubst-adv.sh < "$DEPLOYMENTFILE" | kubectl apply "$@" -f -

