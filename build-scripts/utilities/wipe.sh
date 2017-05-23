#!/bin/bash

# this script will wipe a kubernetes cluster. Meant for local development purposes


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


getresource() {
    kubectl get "$1" | grep -P '^(?!NAME).*' | sed -r "s/^([a-zA-Z0-9-]+).*/$1\/\1/"
}




read -p "Are you sure? [y/N]"
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Deleting services (1/4)"
    kubectl delete $(getresource svc)
    echo "Deleting statfulsets (2/4)"
    kubectl delete $(getresource statefulsets)
    echo "Deleting deployments (3/4)"
    kubectl delete $(getresource deploy)
    echo "Deleting pods (4/4)"
    kubectl delete $(getresource po)
fi


