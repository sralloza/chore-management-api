"""Database basic connections."""

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from ..core.config import settings

# Link to a async tutorial
# https://testdriven.io/blog/fastapi-sqlmodel/#alembic
url = "mysql+pymysql://{username}:{password}@{host}:{port}/{database}".format(
    **settings.database.dict()
)
engine = create_engine(url, pool_pre_ping=True, connect_args={})

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
