#!/bin/bash

# this script checks and waits for the ecosystem to be up.


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


getstatus() {
    local resource=$1
    local status=$(kubectl describe "$resource" | egrep Status: | sed -r 's/Status:\s+//')

    case "$status" in
        Running)
            echo "Running"
            ;;
        Pending|ContainerCreating)
            echo "Pending"
            ;;
        *)
            echo "Failed"
            ;;
    esac
}

