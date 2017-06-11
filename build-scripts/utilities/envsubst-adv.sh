#!/bin/bash

# any data piped through this script will be processed like a heredoc and spit back out after
# substituting any subshell or env vars.

# example:
# $ echo 'We are in $(pwd) and profile is at $HOME' | ./envsubst-adv.sh


# run inside proj dir and use project env
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$DIR"
source "build-scripts/utilities/project-env.sh"



# the EOF for the heredoc
EOF=$(cat /dev/urandom | tr -dc 'A-Z' | fold -w 32 | head -n 1)

# start of the heredoc
INPUT="cat <<$EOF"

# read input into the heredoc
while IFS= read -r line; do
  INPUT=$(printf "%s\n%s" "$INPUT" "$line")
done
INPUT=$(printf "%s\n%s" "$INPUT" "$line")

# close off the heredoc
INPUT=$(printf "%s\n$EOF\n\n" "$INPUT")

# defaults for vars
CONTAINER_VERSION=${CONTAINER_VERSION:-latest}
SCALE=${SCALE:-1}
DATADISKSIZE=${DATADISKSIZE:-1Gi}

# evaluate the input
eval "$INPUT"

