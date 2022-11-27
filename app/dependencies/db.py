"""Database dependencies."""

from app.db.session import SessionLocal, engine
from sqlmodel import Session

def get_db():
    """Creates a local database session."""
    session = Session(engine)
    try:
        yield session
    finally:
        session.close()
        engine.dispose()
