#!/bin/bash

# this script makes sure the local dev pod is running. The local dev pod will have
# a running application that restarts when any js file is modified (using nodemon).
# Furthermore, files are continually synced between the local dev folder and the
# pod. To do this a mount must be created in virtualbox (see README.md)


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


red() { >&2 echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

# build a container just for us! It's based on the web image
TAG=$(imagetag web)
docker build -t "local/local-dev" --cache-from "local/local-dev" - <<EOF
FROM $TAG

# development env so it installs all packages
ENV NODE_ENV development

RUN apt-get update && apt-get install -y inotify-tools rsync && rm -rf /etc/app/lists

# remove the existing app
RUN rm -rf /usr/src/app && mkdir /usr/src/app && rm -rf /var/lib/apt/lists/*

RUN npm install -g nodemon

# container continually syncs while running
CMD ["bash", "-c", "\
synfiles() ( rsync -avz --delete --exclude 'node_modules' --exclude 'package-lock.json' /usr/src/app-host/ /usr/src/app; ) ;\
synloop() ( while true; do synfiles; sleep 5; done; ) ; \
synfiles && npm install --no-optional; \
synloop & nodemon --inspect=0.0.0.0:5858 -nolazy index.js"]

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
    echo "(guessing virtualbox) and create the mount manually."
    exit 4
else
    echo "mount exists!"
fi



echo "configuring debug services..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: local-dev-debugger
  labels:
    app: local-dev-debugger
spec:
  ports:
    - name: debugger
      port: 5858
      nodePort: 31858
  type: NodePort
  selector:
    app: local-dev
---
apiVersion: v1
kind: Service
metadata:
  name: local-dev
  labels:
    app: local-dev
spec:
  ports:
    - name: http
      port: 3000
      nodePort: 31000
  type: NodePort
  selector:
    app: local-dev
EOF



echo "Creating dev pod..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: local-dev
  labels:
    app: local-dev
spec:
  containers:
  - name: local-dev
    image: local/local-dev
    imagePullPolicy: IfNotPresent
    volumeMounts:
      - mountPath: /usr/src/app-host
        name: host-mount
    ports:
      - name: debug
        containerPort: 5858
      - name: http
        containerPort: 3000
    env:
      - name: NODE_ENV
        value: development
      - name: PORT
        value: "3000"
      - name: DEBUG_PORT
        value: "5858"
  volumes:
    - name: host-mount
      hostPath:
        # directory location on host
        path: /motes/web
EOF



RUNNING=0
for i in 1 2 3 4 5 6 7 8 9 10; 
do
    RUNNINGOUTPUT=$(kubectl get pods -l "app==local-dev" --output=yaml | grep 'phase: Running')
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

# kill any existing running nodejs instances
# kubectl exec local-dev -t -- bash -c 'for pid in $(ps -ef | grep -E ":[0-9][0-9] node" | awk "{print \$2}"); do kill -9 $pid; done'



# run npm install on pod
# echo "Running npm install"
# kubectl exec local-dev -t -- npm install --no-optional
