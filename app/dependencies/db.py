"""Database dependencies."""

from sqlmodel import Session

from app.db.session import engine


def get_db():
    """Creates a local database session."""
    session = Session(engine)
    try:
        yield session
    finally:
        session.close()
        engine.dispose()
