#!/bin/bash
POD=${1:-web}

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color


# copy  files in
./copy-files-to-k8s.sh

# run tests
kubectl exec $POD -t -- npm test

# check output
if [[ $? == 0 ]]; then
    echo -e "${GREEN}Tests passed!${NC}"
    exit 0;
else
    >&2 echo -e "${RED}Tests failed!${NC}"
    exit 1;
fi