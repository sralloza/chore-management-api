#!/usr/bin/env bash

function getSettings() {
    python -c "from json import dumps;from app.core.config import settings;print(dumps(settings.dict()))"
}

# TODO: should support al list of addresses, like "database:3306,redis:6379"
if [ -z "$WAIT_FOR_IT_ADDRESS" ]; then
    echo "\$WAIT_FOR_IT_ADDRESS is not set"
else
    echo "Executing 'wait-for-it.sh -t 0 $WAIT_FOR_IT_ADDRESS'"
    /data/wait-for-it.sh -t 0 "$WAIT_FOR_IT_ADDRESS"
fi

databaseSettings=(getSettings | jq -r '.database')
echo "Database settings: $databaseSettings"

createDatabase=(echo "$databaseSettings" | jq -r '.create_database')
if [ "$createDatabase" == "true" ]; then
    echo "Creating database..."
    python utils/init_database.py
fi

runMigrations=(echo "$databaseSettings" | jq -r '.run_migrations')
if [ "$runMigrations" == "true" ]; then
    echo "Running migrations..."
    alembic upgrade head
fi

exec "$@"
