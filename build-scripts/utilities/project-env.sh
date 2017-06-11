#!/bin/bash

# This script sets up a few environment variables for our project

export PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd )"

function get_parm()
{
    echo $([[ $(cat "$PROJECT_DIR/terraform.tfvars" | grep "^$1") =~ \"(.+)\" ]] && echo  "${BASH_REMATCH[1]}")
}

export PROJECT_ID=$(get_parm project_id)
export PROJECT_REGION=$(get_parm project_region)
export DNS_NAME=$(get_parm domain)
export CURRENT_VERSION=$(git rev-parse --verify --short HEAD)

# only works on server in gcp
export ZONE=$(curl -s "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google" | egrep -o 'zones.*' | sed 's/zones\///')

# generates a tag for an image. First arg is image name, second arg is version (default is latest)
imagetag() {
    local ver=${2:-latest}
    local host=eu.gcr.io
    local project="$PROJECT_ID"
    local repo="motes-$1"
    echo "$host/$project/$repo:$ver"
}

export -f imagetag