from contextlib import contextmanager
from logging import getLogger
from os import getenv

import mysql.connector

DATABASES = (
    "chore_type",
    "chore",
    "deactivated_weeks",
    "rotations",
    "settings",
    "ticket",
    "transfer",
    "user",
)

logger = getLogger(__name__)


@contextmanager
def open_database(commit: bool = False, **cur_kwargs):
    user = getenv("MYSQL_USER", "root")
    password = getenv("MYSQL_PASSWORD", "root")
    host = getenv("MYSQL_HOST", "localhost")
    database = getenv("MYSQL_DATABASE", "chore-management")
    port = int(getenv("MYSQL_PORT", "3306"))

    kwargs = dict(host=host, user=user, password=password, database=database, port=port)
    logger.debug("Connecting to database: {}", kwargs)
    conn = mysql.connector.connect(**kwargs)
    yield conn.cursor(**cur_kwargs)
    if commit:
        conn.commit()
    conn.close()


def reset_databases():
    with open_database(commit=True) as cursor:
        for db in DATABASES:
            cursor.execute(f"DELETE FROM {db}")


def execute_query(query: str, data, commit: bool = False):
    with open_database(commit=commit) as cursor:
        cursor.execute(query, data)
        return cursor.fetchall()


if __name__ == "__main__":
    reset_databases()
