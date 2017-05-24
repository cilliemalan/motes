#!/bin/bash

# Tests that the build agent environment is adequite.
# This script returns nonzero if anything is amiss.


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


red() { echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

echo "Current environment:"
printenv
printf "\n\n"

echo "Current user: $USERNAME"
echo "Current groups: $(groups)"
echo "More info user info: $(id)"
echo "Ip Address: $(curl -s 'https://api.ipify.org')"
echo "Home dirs: $(ls /home)"

STATUS=0

if (sudo -v&>/dev/null); then red "Could sudo"; STATUS=1; else green "Could not sudo"; fi

echo "Checking Docker:"
if docker --version; then green "Docker good!"; else red "Docker fail"; STATUS=1; fi
if docker ps; then green "Docker perms good!"; else red "Docker perms fail"; STATUS=1; fi

echo "Checking Kubectl:"
if [[ -n $"(which kubectl)" ]]; then green "Kubectl good!"; else red "Kubectl fail"; STATUS=1; fi

echo "Checking Terraform:"
if terraform --version; then green "Terraform good!"; else red "Terraform fail"; STATUS=1; fi

echo "Checking Node:"
if node --version && npm --version; then green "Node good!"; else red "Node fail"; STATUS=1; fi

echo "Checking gcloud:"
if gcloud version; then green "gcloud good!"; else red "gcloud fail"; STATUS=1; fi


echo -e "\n\n\n"
if [[ $STATUS == 0 ]]; then green "All good!"; else red "Something failed"; fi
echo -e "\n\n\n"
exit $STATUS