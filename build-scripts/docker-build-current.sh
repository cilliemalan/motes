#!/bin/bash

# This script builds all docker images fresh
# and tags them with the current commit hash
# as a version


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"

build-scripts/utilities/docker-build-all.sh --autoversion


