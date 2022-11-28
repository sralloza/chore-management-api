"""Database basic connections."""

import databases
import sqlalchemy

from ..core.config import settings

url = "mysql+aiomysql://{username}:{password}@{host}:{port}/{database}".format(
    **settings.database.dict()
)

database = databases.Database(url)

metadata = sqlalchemy.MetaData()
