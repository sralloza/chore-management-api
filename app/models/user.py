from sqlalchemy import Column, String

from ..db.base import Base


class User(Base):
    __tablename__ = "users"
    id = Column(String(40), primary_key=True)
    username = Column(String(50), nullable=False)
    api_key = Column(String(36), nullable=False, unique=True)
