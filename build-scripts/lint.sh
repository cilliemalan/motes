#!/bin/bash


DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/project-env.sh"

red() { echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

cd web

if node_modules/.bin/eslint .; then
    green No linting problems found
    exit 0
else
    red linting problems!
    exit 1
fi
