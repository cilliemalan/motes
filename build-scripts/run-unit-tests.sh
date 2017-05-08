#!/bin/bash

# this script runs all unit tests inside the current kubernetes environment.
# assumes the deployment is up to date and kubectl is configured properly.


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


red() { >&2 echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

# build a container just for us!
VER=latest
HOST=eu.gcr.io
PROJECT="$PROJECT_ID"
REPO=motes-web
FROMTAG="$HOST/$PROJECT/$REPO:$VER"
docker build -t "local/unit-tests" --cache-from "local/unit-tests" - <<EOF
FROM $FROMTAG
ENV NODE_ENV development
RUN npm install
EOF

if [[ $? != 0 ]]; then
    echo "Failed to build test image"
    exit 4
fi

# run a pod for them tests
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: unit-tests
  labels:
    app: unit-tests
spec:
  containers:
  - name: unit-tests
    image: local/unit-tests
    imagePullPolicy: IfNotPresent
    command: ["sleep"]
    args: ["10000000"]
    env:
    - name: NODE_ENV
      value: development
EOF



RUNNING=0
for i in 1 2 3 4 5; 
do
    RUNNINGOUTPUT=$(kubectl get pods -l "app==unit-tests" --output=yaml | grep 'phase: Running')
    if [[ -n $RUNNINGOUTPUT ]]; then
        RUNNING=1
        break
    fi
done

if [[ $RUNNING == 0 ]]; then
    echo "Could not get pod running"
    kubectl delete po/unit-tests
    exit 3;
fi

# run npm install again
kubectl exec unit-tests -t -- npm install

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