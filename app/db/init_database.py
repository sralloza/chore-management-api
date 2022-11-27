import sqlalchemy as sa
from sqlalchemy import create_engine

from ..core.config import settings
from .session import url

GET_DB_QUERY = (
    "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '{}'"
)
CREATE_DB_QUERY = "CREATE DATABASE `{}` CHARACTER SET = `{}`"

engine = create_engine(url.rsplit("/", 1)[0], pool_pre_ping=True, connect_args={})


def database_exists() -> bool:
    with engine.begin() as conn:
        result = conn.execute(sa.text(GET_DB_QUERY.format(settings.database.database)))

    databases = result.fetchone()
    return bool(databases)


def init_db():
    if settings.database.create_database:
        if database_exists():
            print("Database does exist")
            return

        print("Creating database")
        text = CREATE_DB_QUERY.format(settings.database.database, "UTF8MB4")
        with engine.begin() as conn:
            conn.execute(sa.text(text))


def init_db_sync():
    init_db()
