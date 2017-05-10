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


imagetag() {
    local ver=latest
    local host=eu.gcr.io
    local project="$PROJECT_ID"
    local repo="motes-$1"
    echo "$host/$project/$repo:$ver"
}

export -f imagetag