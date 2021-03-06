#!/bin/bash

# this script builds all docker images. Loops through subdirs of project folder
# and builds every dockerfile. Will tag each image with current commit hash as version
# as well as latest
# options:
#   --pull    pulls all dep repos afresh
#   --push    pushes to gcp repo


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"


docker ps >/dev/null 2>&1
if [[ $? != 0 ]]; then
    echo "Docker failed. Please check docker environment"
    docker ps
    exit 1;
fi

red() { echo -e "\033[0;31m$@\033[0m"; }
green() { echo -e "\033[0;32m$@\033[0m"; }

# builds the dockerfile in the current dir.
# If --pull is passed, will pull. Otherwise cache.
# If --push, will gcloud push
buildcurrent() (
    set -e

    # use commit hash version
    HASHTAG=$(imagetag "${PWD##*/}" "$CURRENT_VERSION")
    TAG=$(imagetag "${PWD##*/}")

    if [[ " $* " =~ " --pull " ]]; then
        # build from scratch
        echo "Building from scratch"
        docker build -t "$HASHTAG" -t "$TAG" --pull .
    else
        # build with cache
        echo "Building with cache"
        docker build -t "$HASHTAG" -t "$TAG" --cache-from "$TAG" .
    fi

    if [[ $? == 0 ]]; then
        if [[ " $* " =~ " --push " ]]; then
            gcloud docker -- push "$HASHTAG"
            gcloud container images add-tag "$TAG"
        fi
    fi

    
)

FAILED=0

time {
    for subdir in */
    do
        cd "$DIR/$subdir"
        if [[ -f Dockerfile ]]; then
            buildcurrent "$@"
            if [[ $? != 0 ]]; then
                FAILED=1;
                red "Failed to build $subdir"
            else
                green "Built $subdir"
            fi
        fi
    done
}
if [[ $FAILED != 0 ]]; then
    red "Something failed"
    exit 1
else
    green "All images built successfully"
fi

exit 0;