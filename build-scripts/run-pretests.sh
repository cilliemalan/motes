#!/bin/bash

# this script runs tests outside of the run environment. These are typically unit tests
# that don't require any integration


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"

red() { >&2 echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }


RESULT=0

cd web
npm install
if [[ $? != 0 ]]; then red "failed to NPM install"; RESULT=$?; fi

npm run test
if [[ $? != 0 ]]; then red "failed to run tests"; RESULT=$?; fi

node_modules/.bin/eslint .
if [[ $? != 0 ]]; then red "There were linting problems"; RESULT=$?; fi


if [[ $RESULT == 0 ]]; then
    green No problems found
    exit 0
else
    red There were problems!
    exit 1
fi

