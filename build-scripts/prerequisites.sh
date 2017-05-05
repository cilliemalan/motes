#!/bin/bash


DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/project-env.sh"

red() { echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

cd web

green "Using npm version $(npm --version)"
echo "Running npm install"

if npm install; then
    green npm install succeeded
    exit 0
else
    red npm install failed
    exit 1
fi


