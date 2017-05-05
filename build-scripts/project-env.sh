#!/bin/bash

# This script sets up a few environment variables for our project

export PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

function get_parm()
{
    echo $([[ $(cat "$PROJECT_DIR/terraform.tfvars" | grep "^$1") =~ \"(.+)\" ]] && echo  "${BASH_REMATCH[1]}")
}

export PROJECT_ID=$(get_parm project_id)
export PROJECT_REGION=$(get_parm project_region)
export DNS_NAME=$(get_parm domain)
