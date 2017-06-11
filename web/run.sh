#!/bin/bash

# change to current dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# setup project env
source ../build-scripts/utilities/project-env.sh


echo "Killing any running node instances inside container"
echo "running program inside pod"
kubectl exec local-dev -- bash -c 'PIDS=$(ps -A | grep node | egrep -o "^ *[0-9]+" | egrep -o "[0-9]+");for pid in $PIDS; do echo "killing $pid"; kill $pid; done; node --debug=0.0.0.0:5858 -nolazy index.js' &


# echo "Opening in browser..."
# minikube service local-dev

disown
exit 0