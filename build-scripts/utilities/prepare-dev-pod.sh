#!/bin/bash

# this script runs makes sure the unit test pod is running, kills any existing
# nodejs instances, and runs npm install in dev env


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


red() { >&2 echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

# build a container just for us! It's based on the web image
TAG=$(imagetag web)
docker build -t "local/web-dev" --cache-from "local/web-dev" - <<EOF
FROM $TAG

# development env so it installs all packages
ENV NODE_ENV development

RUN apt-get update && apt-get install -y inotify-tools rsync && rm -rf /etc/app/lists

# remove the existing app
RUN rm -rf /usr/src/app && mkdir /usr/src/app && rm -rf /var/lib/apt/lists/*

# container continually syncs while running
CMD ["bash", "-c", "while true; do rsync -avz --exclude 'node_modules' /usr/src/app-host/ /usr/src/app; sleep 5; done"]

EOF

if [[ $? != 0 ]]; then
    echo "Failed to build dev image"
    exit 4
fi

# Make sure minikube has the needed mount
# NOTE: THIS IS NOT WORKING DUE TO BUG IN MINIKUBE
# minikube mount "$DIR:/motes"
echo "Checking if minikube mount exists..."
MOUNT_EXISTS=$(minikube ssh -- "if [[ -e /motes ]]; then echo exists; fi")
if [[ $MOUNT_EXISTS != "exists" ]]; then
    red "The mount /motes inside the minikube vm does not exist"
    red "Due to a bug in minikube we can't do this for you"
    echo"You need to mount the folder within minikube called /motes to $(pwd)"
    echo "This is typically done with the command:"
    echo
    echo "  minikube mount '$DIR:/motes'"
    echo
    echo "But this will probably not work. As a workaround use your VM driver"
    echo "(probably virtualbox) and create the mount manually."
    # exit 4
else
    echo "mount exists!"
fi

# run a pod for dev stuff
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: web-dev
  labels:
    app: web-dev
spec:
  containers:
  - name: web-dev
    image: local/web-dev
    imagePullPolicy: IfNotPresent
    volumeMounts:
    - mountPath: /usr/src/app-host
      name: host-mount
  volumes:
  - name: host-mount
    hostPath:
      # directory location on host
      path: /motes/web
EOF



RUNNING=0
for i in 1 2 3 4 5 6 7 8 9 10; 
do
    RUNNINGOUTPUT=$(kubectl get pods -l "app==web-dev" --output=yaml | grep 'phase: Running')
    if [[ -n $RUNNINGOUTPUT ]]; then
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
# pushd web
# tar -X .gitignore -cpzf - . | kubectl exec -i unit-tests -- tar -xpzf - .;
# popd

# run npm install on pod
echo "Running npm install"
kubectl exec web-dev -t -- npm install
