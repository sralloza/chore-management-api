#!/usr/bin/env bash

set -ueo pipefail

cd app
poetry run isort .
poetry run black .
poetry run ruff .

cd ../test
poetry run isort .
poetry run black .
poetry run ruff --ignore F403,F405 .

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
