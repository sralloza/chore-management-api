#!/usr/bin/env bash

set -e

cd test
poetry run isort .
poetry run black .
# poetry run pytest -m 'not responses'

cd ..
npm run format

dirtyFiles="$(git status -s)"
if [[ "$dirtyFiles" != "" ]]; then
  echo "Linting failed"
  echo "Changed files:"
  echo "$dirtyFiles"
  exit 1
fi
