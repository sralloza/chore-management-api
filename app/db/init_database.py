import sqlalchemy as sa
from sqlalchemy.ext.asyncio import create_async_engine

from ..core.config import settings
from .session import url

GET_DB_QUERY = (
    "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '{}'"
)
CREATE_DB_QUERY = "CREATE DATABASE `{}` CHARACTER SET = `{}`"

engine = create_async_engine(url.rsplit("/", 1)[0], pool_pre_ping=True, connect_args={})


async def database_exists() -> bool:
    async with engine.begin() as conn:
        result = await conn.execute(
            sa.text(GET_DB_QUERY.format(settings.database.database))
        )

    databases = result.fetchone()
    return bool(databases)


async def init_db():
    if settings.database.create_database:
        if await database_exists():
            print("Database does exist")
            return

        print("Creating database")
        text = CREATE_DB_QUERY.format(settings.database.database, "UTF8MB4")
        async with engine.begin() as conn:
            await conn.execute(sa.text(text))


def init_db_sync():
    import asyncio

    loop = asyncio.get_event_loop()
    loop.run_until_complete(init_db())
