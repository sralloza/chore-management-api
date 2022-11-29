#!/usr/bin/env bash

set -ueo pipefail

cd app
poetry run ruff .
poetry run isort .
poetry run black .

cd ../test
poetry run isort .
poetry run black .
# poetry run ruff .

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
