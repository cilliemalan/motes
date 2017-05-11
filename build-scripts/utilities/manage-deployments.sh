#!/bin/bash

# utility script to create deployments. Run for usage


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"

# spits out usage
printusage() {
    cat <<USAGE
Utility to manage kubernetes deployments.

Note: kuberentes environment must be set up prior to using this utility.

Usage: ./create.sh [options]

    deployment is one of the .yaml files without the ".yaml". e.g. ./create.sh web

Options:
    -e, --env ENVIRONMENT   Use the specified environment (defaults to dev. valid
                            values are: dev, test, prod).
    -p, --project PROJECT   Override the project ID to get images from. By default will
                            get from ./project-env.sh
    -s, --scale SCALE       Override scale factor (by default dev=1, test=3, and prod=5).
                            This controls how many initial instances of services such
                            as kafka, zookeeper, and web are created
    -v, --version VERSION   the version tag to use for deployment-based containers. by
                            default will use 'latest'.
    -n, --namespace NAMESPACE set the kubernetes namespace to use. If omitted will use
                            the current namespace.
        --delete            delete all deployments instead of create
        --dry-run           dry run
USAGE
}


red() { echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

# parse args
SHORT_OPTIONS=e:p:s:n:v:
LONG_OPTIONS=env:,project:,scale:,namespace:,delete,dry-run,version:

PARSED=$(getopt --options $SHORT_OPTIONS --longoptions $LONG_OPTIONS --name "$0" -- "$@")
if [[ $? -ne 0 ]]; then
    printusage
    exit 2
fi

# ingest args
eval set -- "$PARSED"


export ENVIRONMENT=dev
export SCALE=0
export CONTAINER_VERSION=latest
DELETE_DEPLOYMENTS=0
DRY_RUN=0
# PROJECT_ID from project-env

while true; do
    case "$1" in
        -e|--env)
            ENVIRONMENT="$2"
            shift 2
            ;;
        -p|--project)
            PROJECT_ID="$2"
            shift 2
            ;;
        -s|--scale)
            SCALE="$2"
            shift 2
            ;;
        -n|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -v|--version)
            CONTAINER_VERSION="$2"
            shift 2
            ;;
        --delete)
            DELETE_DEPLOYMENTS=1
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Unknown: $1"
            printusage
            exit 3
            ;;
    esac
done

# handle non-option arguments
if [[ $# != 0 ]]; then
    printusage
    exit 4
fi

# some per-env things
DEFAULTSCALE=0
export DATADISKSIZE=1Gi
case "$ENVIRONMENT" in
    dev)
        DEFAULTSCALE=1
        ;;
    test)
        DEFAULTSCALE=3
        ;;
    prod)
        DEFAULTSCALE=5
        DATADISKSIZE=20Gi
        ;;
    *)
        echo "Invalid environment"
        printusage
        exit 5
        ;;
esac

if [[ $SCALE == 0 ]]; then
    SCALE=$DEFAULTSCALE
fi

export DOUBLESCALE=$((SCALE*2))
export TRIPLESCALE=$((SCALE*3))


KUBE_CONTEXT=$(kubectl config current-context)

if [[ -z "$KUBE_CONTEXT" || $? != 0 ]]; then
    red "Could not get kubernetes context."
    echo "Please make sure k8s context is set up" >2
    exit 6
fi

echo "Using:"
echo "  Kubernetes ctx:    $KUBE_CONTEXT"
echo "  Project:           $PROJECT_ID"
echo "  Scale:             $SCALE"
echo "  Environment:       $ENVIRONMENT"
echo "  Data Disk Size:    $DATADISKSIZE"
echo "  Container version: $CONTAINER_VERSION"


# creates a deployment
createdeployment() {
    local deploymentfile=$1
    local namespacearg

    if [[ -n "$NAMESPACE" ]]; then
        args="$args --namespace '$NAMESPACE'"
    fi

    local command=apply
    local args=""
    if [[ $DELETE_DEPLOYMENTS == 1 ]]; then
        command=delete
    fi

    if [[ $DRY_RUN == 1 ]]; then
        args="$args --dry-run=true"
    fi

    # sub environment into the deployment file and pass to kubectl
    envsubst < "$DIR/$deploymentfile" |\
        kubectl $command $namespacearg $args -f -
}


# create each yaml file in deployments dir
FAILED=0
for deploymentfile in deployments/*.yaml;
do
    createdeployment "$deploymentfile"
    if [[ $? != 0 ]]; then
        FAILED=1
        red "Failed to create $deploymentfile"
    else
        green "processed $deploymentfile"
    fi
done

if [[ $FAILED != 0 ]]; then
    red "At least one deployment failed"
    exit 1
else
    green "All succeeded"
    exit 0
fi