#!/bin/bash

# this script runs tests outside of the run environment. These are typically unit tests
# that don't require any integration


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"

cd web
npm install
npm run test

