from contextlib import contextmanager
from logging import getLogger
from os import getenv

import mysql.connector
from hamcrest import assert_that, is_in

logger = getLogger(__name__)
DATABASES = (
    "chore_types",
    "chores",
    "rotations",
    "skipped_weeks",
    "tenants",
    "tickets",
    "transfers",
)


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


def validate_table_name(table_name):
    assert_that(table_name, is_in(DATABASES), "Unregistered table name")


def list_table_rows(table_name: str):
    validate_table_name(table_name)
    with open_database(commit=False, dictionary=True) as cursor:
        cursor.execute(f"SELECT * FROM {table_name}")
        return cursor.fetchall()


def save_to_database(table_name: str, data):
    validate_table_name(table_name)
    if not isinstance(data, (list, tuple)):
        data = [data]

    keys = list(data[0].keys())

    fields = ", ".join(keys)
    format_fields = ", ".join([f"%({x})s" for x in keys])
    query = f"INSERT INTO {table_name} ({fields}) VALUES ({format_fields})"

    with open_database(commit=True) as cursor:
        cursor.executemany(query, data)
