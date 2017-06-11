#!/bin/bash

# any data piped through this script will be processed like a heredoc and spit back out after
# substituting any subshell or env vars.

# example:
# $ echo 'We are in $(pwd) and profile is at $HOME' | ./envsubst-adv.sh

transform_piped() {
    echo start
    while read x ; do echo "-$x" ; done
    echo end
}
EOF=$(cat /dev/urandom | tr -dc 'A-Z' | fold -w 32 | head -n 1)
INPUT="cat <<$EOF"
while read x ; do
    INPUT=$(printf "%s\n%s" "$INPUT" "$x")
done
INPUT=$(printf "%s\n$EOF\n\n" "$INPUT")

eval "$INPUT"

