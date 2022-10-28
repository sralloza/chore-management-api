#!/usr/bin/env bash

mustExit=false

function cleanup {
  docker-compose down -v
  mustExit=true
}

trap cleanup INT

docker-compose up --build -d

# TODO: use for loop to fail after 5 minutes
until [[ $(docker inspect -f "{{ .State.Health.Status }}" app) = "healthy" ]]; do
  if [[ "$mustExit" = "true" ]]; then
    exit 1
  fi

  echo "Waiting for app to start..."
  sleep 1;
done;

echo "App is running"

testsOk=true
rm -rf test/reports
behave -t=-old

if [[ $? -ne 0 ]]; then
  testsOk=false
fi

if [[ "$testsOk" = "true" ]]; then
  echo "Tests passed"
  cleanup
else
  echo "Tests failed"
  if tty -s; then
    echo "tty detected, launching allure"
    allure serve test/reports
  else
    echo "tty not detected, showing docker-compose logs"
    docker-compose logs
    cleanup
  fi
  exit 1
fi
