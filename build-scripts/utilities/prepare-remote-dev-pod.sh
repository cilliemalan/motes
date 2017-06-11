#!/bin/bash

# this script makes sure the dev pod is running in the current k8s cluster, kills any
# existing nodejs instances, and runs npm install in dev env. This is for a remote cluster.


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


red() { >&2 echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

# build a container just for us! It's based on the web image
TAG=$(imagetag web)
docker build -t "local/remote-dev" --cache-from "local/remote-dev" - <<EOF
FROM $TAG

# development env so it installs all packages
ENV NODE_ENV development

# container continually syncs while running
CMD ["sleep", "1000000"]

EOF

if [[ $? != 0 ]]; then
    echo "Failed to build dev image"
    exit 4
fi

# run a pod for dev stuff
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: remote-dev
  labels:
    app: remote-dev
spec:
  containers:
  - name: remote-dev
    image: local/remote-dev
    imagePullPolicy: IfNotPresent
EOF



RUNNING=0
for i in 1 2 3 4 5 6 7 8 9 10; 
do
    RUNNINGOUTPUT=$(kubectl get pods -l "app==remote-dev" --output=yaml | grep 'phase: Running')
    if [[ -n "$RUNNINGOUTPUT" ]]; then
        RUNNING=1
        break
    fi
    sleep 1
done

if [[ $RUNNING == 0 ]]; then
    echo "Could not get pod running"
    exit 3;
fi

# copy files in
# echo "Copying in files..."
pushd web
tar -X .gitignore -cpzf - . | kubectl exec -i remote-dev -- tar -xpzf - .;
popd

# run npm install on pod
echo "Running npm install"
kubectl exec remote-dev -t -- npm install
