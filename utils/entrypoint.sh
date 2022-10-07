#! /usr/bin/env bash

# TODO: should support al list of addresses, like "database:3306,redis:6379"
if [[ -z "${WAIT_FOR_IT_ADDRESS}" ]]; then
  echo "Skipping wait-for-it ($$WAIT_FOR_IT_ADDRESS is not defined)"
else
  echo "running wait-for-it.sh -t 0 ${WAIT_FOR_IT_ADDRESS}"
  /app/wait-for-it.sh -t 0 "${WAIT_FOR_IT_ADDRESS}"
fi

java -jar /app/chore-management-api.jar
