from logging import getLogger
from os import getenv

import mysql.connector

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


def reset_databases():
    user = getenv("MYSQL_USER", "root")
    password = getenv("MYSQL_PASSWORD", "root")
    host = getenv("MYSQL_HOST", "localhost")
    database = getenv("MYSQL_DATABASE", "chore-management")
    port = int(getenv("MYSQL_PORT", "3306"))

    kwargs = dict(host=host, user=user, password=password, database=database, port=port)
    logger.debug("Connecting to database: {}", kwargs)
    conn = mysql.connector.connect(**kwargs)
    cursor = conn.cursor()

    for db in DATABASES:
        cursor.execute(f"DELETE FROM {db}")
    conn.commit()
    conn.close()
