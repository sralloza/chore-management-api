#!/usr/bin/env bash

cd test
poetry run isort .
poetry run black .

cd ..
npm run format

if [[ "$(git status --porcelain)" != "" ]]; then
  echo "Linting failed'"
  exit 1
fi
