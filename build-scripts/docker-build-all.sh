#!/bin/bash

# builds the dockerfile in the current dir. if --canary is passed, version will be
# canary. If --pull is passed, will pull. Otherwise cache.
buildcurrent() {
    if [[ " $* " =~ " --canary " ]]; then
    VER=canary
    else
        VER=latest
    fi

    HOST=eu.gcr.io
    PROJECT="$PROJECT_ID"
    REPO=motes-${PWD##*/}
    TAG="$HOST/$PROJECT/$REPO:$VER"

    if [[ " $* " =~ " --pull " ]]; then
        # build from scratch
        docker build -t "$TAG" --pull .
    else
        # build with cache
        docker build -t "$TAG" --cache-from "$TAG" .
    fi
}

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DIR"
source "build-scripts/project-env.sh"


time {
    for subdir in */
    do
        cd "$DIR/$subdir"
        if [[ -f Dockerfile ]]; then
            buildcurrent "$@"
        fi
    done
}
