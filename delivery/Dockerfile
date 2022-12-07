FROM python:3.10.8-alpine3.16

RUN apk add bash curl gcc jq musl-dev libffi-dev && \
    curl -sSL https://install.python-poetry.org | python - && \
    cd /usr/local/bin && \
    ln -s /root/.local/bin/poetry

ENV POETRY_VIRTUALENVS_CREATE false

WORKDIR /app

COPY pyproject.toml poetry.lock README.md ./

RUN poetry install --only main --no-root

COPY alembic/ /app/alembic

COPY alembic.ini /app/

COPY ./app /app/app

COPY ./utils /app/utils

RUN poetry install --only main

COPY ./delivery /utils/

COPY API.md ./

RUN chmod +x /utils/*.sh

EXPOSE 8080

ENTRYPOINT [ "/utils/entrypoint.sh" ]

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
