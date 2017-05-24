#!/bin/bash

# this script runs all unit tests inside the current kubernetes environment.
# assumes the deployment is up to date and kubectl is configured properly.


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


red() { >&2 echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

#prepare unit test pod
build-scripts/utilities/prepare-dev-pod.sh


# run tests
kubectl exec unit-tests -ti -- npm run test-all
RESULT=$?

# check output
if [[ $RESULT == 0 ]]; then
    green "Tests passed!"
    exit 0
else
    red "Tests failed"
    exit 1
fi