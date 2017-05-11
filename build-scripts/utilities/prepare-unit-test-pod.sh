#!/bin/bash

# this script runs makes sure the unit test pod is running, kills any existing
# nodejs instances, and runs npm install in dev env


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
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

# development env so it installs all packages
ENV NODE_ENV development

# npm install for caching. Will be run again
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
    exit 3;
fi

# copy files in
echo "Copying in files..."
pushd web
tar -X .gitignore -cpzf - . | kubectl exec -i unit-tests -- tar -xpzf - .;
popd

# run npm install again
echo "Running npm install"
kubectl exec unit-tests -t -- npm install
