from sqlalchemy import Boolean, Column, DateTime, Integer, String

from ..db.base import Base


class Transfer(Base):
    __tablename__ = "transfers"

    id = Column(Integer, primary_key=True, autoincrement=True)
    accepted = Column(Boolean, nullable=False)
    chore_type_id = Column(String(25), nullable=False)
    completed = Column(Boolean, nullable=False)
    user_id_from = Column(String(40), nullable=False)
    user_id_to = Column(String(40), nullable=False)
    created_at = Column(DateTime, nullable=False)
    closed_at = Column(DateTime, nullable=True)
    week_id = Column(String(7), nullable=False)
