#!/usr/bin/env bash

set -ueo pipefail

cd app
echo "Linting app"
poetry run black .
poetry run ruff .

cd ../test
echo "Linting tests"
poetry run black .
poetry run ruff .

# poetry run pytest -m 'not responses'

cd ..
npx prettier --write '{app,test,.}/**/*.{js,md,json,ts}'

dirtyFiles="$(git status -s)"
if [[ "$dirtyFiles" != "" ]]; then
  echo "Linting failed"
  echo "Changed files:"
  echo "$dirtyFiles"
  exit 1
fi
