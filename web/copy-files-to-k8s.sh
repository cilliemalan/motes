#!/bin/bash
POD=${1:-web}

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
pushd "$DIR"

echo "Pushing initally to pod $POD";
tar -X .gitignore -cpzf - . | kubectl exec -i $POD -- tar -xpzf - .;

echo "Running inside pod"
kubectl exec -i $POD -- npm install

echo "Killing any running node instances inside container"
kubectl exec $POD -- bash -c 'PIDS=$(ps -A | grep node | egrep -o "^ *[0-9]+" | egrep -o "[0-9]+");for pid in $PIDS; do echo "killing $pid"; kill $pid; done'

popd