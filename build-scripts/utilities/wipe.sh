#!/bin/bash

# this script will wipe a kubernetes cluster. Meant for local development purposes


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


getresource() {
    kubectl get "$1" | grep -P '^(?!NAME).*' | sed -r "s/^([a-zA-Z0-9-]+).*/$1\/\1/"
}




read -p "Are you sure? [y/N]" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Deleting  (1/4)"
    kubectl delete $(getresource svc)
    echo "Deleting  (2/4)"
    kubectl delete $(getresource statefulsets)
    echo "Deleting  (3/4)"
    kubectl delete $(getresource deploy)
    echo "Deleting  (4/4)"
    kubectl delete $(getresource po)
fi


