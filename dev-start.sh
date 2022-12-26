#!/usr/bin/env bash

docker-compose up -d database

python utils/init_database.py
alembic upgrade head

uvicorn app:app --host=0.0.0.0 --port 8080 --reload
