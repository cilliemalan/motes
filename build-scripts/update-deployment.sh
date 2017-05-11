#!/bin/bash

# Updates deployment on current k8s context


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"

# send current version as version to update to
build-scripts/utilities/manage-deployments.sh -v "$CURRENT_VERSION"


# reconfigure proxy
PROXY_PODS="$(kubectl get pods -l "app=web-proxy" | egrep -o "^[a-z0-9-]+")"

for pod in "$PROXY_PODS"; do
echo "reconfiguring $pod"
kubectl exec "$pod" -t -- bash -c "usr/local/etc/haproxy/reconf.sh"
done
