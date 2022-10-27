#!/usr/bin/env bash

function cleanup {
  docker-compose down -v
}

trap cleanup INT

docker-compose up --build -d

utils/wait-for-it.sh localhost:3306 -t 0
utils/wait-for-it.sh localhost:8080 -t 0
utils/wait-for-it.sh localhost:6379 -t 0

sleep 10 && npx prisma migrate deploy

rm -rf test/reports
behave -t=-old

allure serve test/reports
