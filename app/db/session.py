"""Database basic connections."""

from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

from ..core.config import settings

url = "mysql+aiomysql://{username}:{password}@{host}:{port}/{database}".format(
    **settings.database.dict()
)
engine = create_async_engine(url, pool_pre_ping=True, connect_args={})

SessionLocal = sessionmaker(
    autocommit=False, autoflush=False, bind=engine, class_=AsyncSession
)
