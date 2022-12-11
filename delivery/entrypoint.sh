#!/usr/bin/env bash

set -e

function getSettings() {
    python -c "from json import dumps;from app.core.config import settings;print(dumps(settings.dict()))"
}

# TODO: should support al list of addresses, like "database:3306,redis:6379"
if [[ -z "$WAIT_FOR_IT_ADDRESS" ]]; then
    echo "\$WAIT_FOR_IT_ADDRESS is not set"
else
    echo "Waiting for $WAIT_FOR_IT_ADDRESS..."
    for addr in ${WAIT_FOR_IT_ADDRESS//,/ }; do
        echo "Executing 'wait-for-it.sh -t 0 $addr'"
        /utils/wait-for-it.sh -t 0 "$addr"
    done

fi

databaseSettings=$(getSettings | jq -r '.database')
echo "Database settings: $databaseSettings"

createDatabase=$(echo "$databaseSettings" | jq -r '.create_database')
if [[ "$createDatabase" == "true" ]]; then
    echo "Creating database..."
    python utils/init_database.py
fi

runMigrations=$(echo "$databaseSettings" | jq -r '.run_migrations')
if [[ "$runMigrations" == "true" ]]; then
    echo "Running migrations..."
    alembic upgrade head
fi

exec "$@"
