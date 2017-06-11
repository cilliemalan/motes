#!/bin/bash

# Tests that the build agent environment is adequite.
# This script returns nonzero if anything is amiss.


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


red() { >&2 echo -e "\033[0;31m$@\033[0m"; }
green() { >&2 echo -e "\033[0;32m$@\033[0m"; }
white() { >&2 echo "$@"; }

checkprereqs() {
    
    white "Checking prerequisites..."

    echo "Current environment:"
    printenv
    printf "\n\n"

    echo "Current user: $USERNAME"
    echo "Current groups: $(groups 2>/dev/null)"
    echo "More info user info: $(id)"
    echo "Ip Address: $(curl -s 'https://api.ipify.org')"

    STATUS=0

    if (sudo -v&>/dev/null); then red "Could sudo"; STATUS=1; else green "Could not sudo"; fi

    echo "Checking Docker:"
    if docker --version 2>/dev/null; then green "Docker good!"; else red "Docker fail"; STATUS=1; fi
    if docker ps 2>/dev/null; then green "Docker perms good!"; else red "Docker perms fail"; STATUS=1; fi

    echo "Checking Kubectl:"
    if [[ -n $"(which kubectl)" ]]; then green "Kubectl good!"; else red "Kubectl fail"; STATUS=1; fi

    echo "Checking Terraform:"
    if terraform --version; then green "Terraform good!"; else red "Terraform fail"; STATUS=1; fi

    echo "Checking Node:"
    if node --version && npm --version; then green "Node good!"; else red "Node fail"; STATUS=1; fi

    echo "Checking gcloud:"
    if gcloud version; then green "gcloud good!"; else red "gcloud fail"; STATUS=1; fi


    echo -e "\n\n\n"
    if [[ $STATUS == 0 ]]; then
        green "All good!";
    else
        red "Something failed";
        white "Check prereqs.log for more output"
    fi
    echo -e "\n\n\n"
    exit $STATUS

}

checkprereqs 2>&1 1>prereqs.log