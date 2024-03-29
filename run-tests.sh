#!/usr/bin/env bash

mustExit=false
maxRetries=30
retriesLeft="$maxRetries"

python -c "import allure" || exit 2
keepUp=false

if [[ " $@ " =~ " --keep-up=true " ]]; then
  keepUp=true
fi
if [[ " $@ " =~ " --keep-up true " ]]; then
  keepUp=true
fi

function cleanup {
  if [[ "$mustExit" = "false" ]]; then
    if [[ "$keepUp" = "true" ]]; then
      echo "Keeping containers up"
      mustExit=true
      tail -f /dev/null
    fi
  fi
  docker-compose down -v
  mustExit=true
}

function runTests() {
  exitCode=0

  behave
  _exitCode=$?
  echo "+++ behave tests exit code: $_exitCode"
  if [ $_exitCode -ne 0 ]; then
    exitCode=$_exitCode
  fi

  # echo "++ Running responses tests"
  # poetry run pytest test -m 'responses'
  # _exitCode=$?
  # echo "+++ responses tests exit code: $_exitCode"
  # if [ $_exitCode -ne 0 ]; then
  #   exitCode=$_exitCode
  # fi

  echo "all tests exit code: $exitCode"
  return $exitCode
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
runTests

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
