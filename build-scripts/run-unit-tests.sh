#!/bin/bash

# this script runs all unit tests inside the current kubernetes environment.
# assumes the deployment is up to date and kubectl is configured properly.


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


red() { >&2 echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

SCRIPTENV=local;
if [[ "$1" == "local" ]]; then
    echo "Using local environment"
elif [[ "$1" =~ dev|test|prod ]]; then
    echo "Using $1 environment"
    SCRIPTENV=remote
else
    echo "No environment specified, assuming local"
fi

# prepare dev pod
./build-scripts/utilities/prepare-$SCRIPTENV-dev-pod.sh --quick

# run tests
kubectl exec $SCRIPTENV-dev -ti -- npm run test-all
RESULT=$?

# copy out code coverage results
kubectl exec -i local-dev -- tar -cpzf - coverage | tar -xpzf - coverage &
kubectl exec -i local-dev -- tar -cpzf - .nyc_output | tar -xpzf - .nyc_output &
wait


# check output
if [[ $RESULT == 0 ]]; then
    green "Tests passed!"
    exit 0
else
    red "Tests failed"
    exit 1
fi