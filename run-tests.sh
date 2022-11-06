#!/usr/bin/env bash

mustExit=false
maxRetries=30
retriesLeft="$maxRetries"

function cleanup {
  docker-compose down -v
  mustExit=true
}

function testReponses() {
  echo "++ Running responses tests"
  poetry run pytest -m 'responses'
}

trap cleanup INT

docker-compose up --build -d

for (( i=1; i<=$maxRetries; i++ )); do
  if [[ "$mustExit" = "true" ]]; then
    exit 1
  fi

  appStatus="$(docker inspect -f "{{ .State.Health.Status }}" app)"
  if [ "$appStatus" = "healthy" ]; then
    echo "App is healthy"
    break
  else
    echo "Waiting for app to start ($retriesLeft retries left)..."
    sleep 1;
  fi

  retriesLeft=$((maxRetries - i))
done

if [[ "$retriesLeft" -eq "0" ]]; then
  echo "App failed to start"
  echo "Showing docker-compose logs"
  docker-compose logs
  cleanup
  exit 1
fi

testsOk=true
rm -rf test/reports
rm -rf test/output
rm -rf test/reports.zip
behave -t=-old

if [[ $? -ne 0 ]]; then
  testsOk=false
fi

if [[ "$testsOk" = "true" ]]; then
  echo "Tests passed"
  cleanup
  testReponses
else
  echo "Tests failed"
  if tty -s; then
    echo "tty detected, launching allure"
    testReponses
    allure serve test/reports
  else
    echo "tty not detected, showing docker-compose logs"
    docker-compose logs
    testReponses
    cleanup
  fi
  exit 1
fi
