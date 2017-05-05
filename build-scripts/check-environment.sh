#!/bin/bash


red() { echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

echo "Current environment:"
printenv
printf "\n\n"

STATUS=0

if (sudo -v&>/dev/null); then red "Could sudo"; STATUS=1; else green "Could not sudo"; fi

echo "Checking Docker:"
if docker --version; then green "Docker good!"; else red "Docker fail"; STATUS=1; fi

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