#!/usr/bin/env bash

# TODO: should support al list of addresses, like "database:3306,redis:6379"
if [ -z "$WAIT_FOR_IT_ADDRESS" ]; then
    echo "\$WAIT_FOR_IT_ADDRESS is not set"
else
    echo "Executing 'wait-for-it.sh -t 0 $WAIT_FOR_IT_ADDRESS'"
    /data/wait-for-it.sh -t 0 "$WAIT_FOR_IT_ADDRESS"
fi

if [ "$CREATE_DATABASE" == "true" ]; then
    echo "Creating database..."
    npm run db:create
else
    echo "\$CREATE_DATABASE is not set, skipping database creation"
fi

exec "$@"
