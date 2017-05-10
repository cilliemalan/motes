#!/bin/bash

# change to current dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# setup project env
source ../build-scripts/utilities/project-env.sh

echo "configuring debug services..."
kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: web-debug-debugger
  labels:
    app: web-debug-debugger
spec:
  ports:
    - name: debugger
      port: 5858
      nodePort: 31858
  type: NodePort
  selector:
    app: debug-runner
---
apiVersion: v1
kind: Service
metadata:
  name: web-debug
  labels:
    app: web-debug
spec:
  ports:
    - name: http
      port: 3000
      nodePort: 31000
  type: NodePort
  selector:
    app: debug-runner
EOF


if [[ -z "$(kubectl get pods -l "app==debug-runner" | grep Running)" ]]; then


kubectl create -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: debug-runner
  labels:
    app: debug-runner
spec:
  containers:
    - name: debug-runner
      image: $(imagetag web)
      imagePullPolicy: IfNotPresent
      command: ["sleep"]
      args: ["100000"]
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
EOF

  # wait for it to be ready
  RUNNING=0
  for i in 1 2 3 4 5; 
  do
      RUNNINGOUTPUT=$(kubectl get pods -l "app==debug-runner" --output=yaml | grep 'phase: Running')
      if [[ -n $RUNNINGOUTPUT ]]; then
          RUNNING=1
          break
      fi
  done

fi # container running

if [[ $RUNNING == 0 ]]; then
    echo "Could not get pod running"
    kubectl delete po/unit-tests
    exit 3;
fi

echo "Pushing initally to pod debug-runner";
tar -X .gitignore -cpzf - . | kubectl exec -i debug-runner -- tar -xpzf - .;

echo "Killing any running node instances inside container"
kubectl exec debug-runner -- bash -c 'PIDS=$(ps -A | grep node | egrep -o "^ *[0-9]+" | egrep -o "[0-9]+");for pid in $PIDS; do echo "killing $pid"; kill $pid; done'

echo "Running npm inside pod"
kubectl exec -i debug-runner -- npm install

echo "Opening in browser..."
minikube service web-debug

echo "running program inside pod"
kubectl exec debug-runner -- node --debug=0.0.0.0:5858 -nolazy index.js
