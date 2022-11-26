"""Database basic connections."""

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.config import settings
from sqlalchemy_utils import database_exists, create_database


url = "mysql+pymysql://{username}:{password}@{host}:{port}/{database}".format(
    **settings.database.dict()
)
engine = create_engine(url, pool_pre_ping=True, connect_args={})

if not database_exists(engine.url) and settings.database.create_database:
    create_database(engine.url)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
