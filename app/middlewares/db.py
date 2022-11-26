"""Database dependencies."""

from sqlalchemy.ext.asyncio import AsyncSession
from app.db.session import SessionLocal, engine


async def get_db() -> AsyncSession:
    """Creates a local database session."""
    async with SessionLocal() as db:
        try:
            yield db
        finally:
            db.close()
            await engine.dispose()
