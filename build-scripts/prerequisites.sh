#!/bin/bash

# Installs build prereqs (i.e. npm install for unit tests to work).


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"

red() { echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

cd web

green "Using npm version $(npm --version)"
echo "Running npm install"

# track status
FAILED=0

if npm install; then
    green npm install succeeded
else
    red npm install failed
    FAILED=1
fi

if [[ ! -e "$DIR/.cache" ]]; then
    echo "Creating cache dir"
    mkdir -p "$DIR/.cache"
fi

if [[ ! -f "$DIR/.cache/kubectl" ]]; then
    echo "Downloading linux kubectl"
    curl -L -o "$DIR/.cache/kubectl" https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x "$DIR/.cache/kubectl"
fi

if [[ ! -f "$DIR/.cache/cfssl" ]]; then
    echo "Downloading cfssl"
    curl -L -o "$DIR/.cache/cfssl" https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
    chmod +x "$DIR/.cache/cfssl"
fi

if [[ ! -f "$DIR/.cache/cfssljson" ]]; then
    echo "Downloading cfssljson"
    curl -L -o "$DIR/.cache/cfssljson" https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
    chmod +x "$DIR/.cache/cfssljson"
fi

    