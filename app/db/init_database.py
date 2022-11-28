import databases

from ..core.config import settings
from .session import url

GET_DB_QUERY = (
    "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '{}'"
)
CREATE_DB_QUERY = "CREATE DATABASE `{}` CHARACTER SET = `{}`"

url_without_database = url.rsplit("/", 1)[0]
database = databases.Database(url_without_database)


async def database_exists() -> bool:
    result = await database.fetch_one(
        query=GET_DB_QUERY.format(settings.database.database)
    )
    return bool(result)


async def init_db():
    await database.connect()
    if settings.database.create_database:
        if await database_exists():
            print("Database does exist")
            return

        print("Creating database")
        await database.execute(
            query=CREATE_DB_QUERY.format(settings.database.database, "UTF8MB4")
        )


def init_db_sync():
    import asyncio

    loop = asyncio.get_event_loop()
    loop.run_until_complete(init_db())
