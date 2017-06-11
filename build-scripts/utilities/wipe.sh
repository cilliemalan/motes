#!/bin/bash

# this script will wipe a kubernetes cluster. Meant for local development purposes


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


getresource() {
    kubectl get "$1" | grep -P '^(?!NAME).*' | sed -r "s/^([a-zA-Z0-9-]+).*/$1\/\1/"
}

deleteresource() {
    local resourcesToDelete=$(getresource $1)
    if [[ -n "$resourcesToDelete" ]]; then
        kubectl delete $resourcesToDelete
    fi
}

read -p "Are you sure? [y/N]"
if [[ $REPLY =~ ^[Yy]$ ]]
then
    RESOURCES=(svc statefulsets deploy po pvc pv)
    NUMRES=${#RESOURCES[@]}
    CURR=1

    for resource in ${RESOURCES[@]}; do
        echo "Deleting $resource (step $CURR/$NUMRES)"
        deleteresource $resource
    done

fi


