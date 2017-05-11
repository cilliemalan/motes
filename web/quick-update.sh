#!/bin/bash

# change to current dir
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

# setup project env
source ../build-scripts/utilities/project-env.sh


echo "Pushing initally to pod debug-runner";
tar -X .gitignore -cpzf - . | kubectl exec -i debug-runner -- tar -xpzf - .;


