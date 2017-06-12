#!/bin/sh

mongo=( mongo --host 127.0.0.1 --port 27017 --quiet )

mongo+=(
    --username="$MONGO_INITDB_ROOT_USERNAME"
    --password="$MONGO_INITDB_ROOT_PASSWORD"
    --authenticationDatabase="admin"
)

"${mongo[@]}" "$MONGO_INITDB_DATABASE" <<-EOJS
    db.createUser({
        user: $(jq --arg 'user' "$MONGO_INITDB_USERNAME" --null-input '$user'),
        pwd: $(jq --arg 'pwd' "$MONGO_INITDB_PASSWORD" --null-input '$pwd'),
        roles: [ { role: 'dbOwner', db: $(jq --arg 'db' "$MONGO_INITDB_DATABASE" --null-input '$db') } ]
    })
EOJS

