from sqlalchemy import Column, String, Integer, Boolean

from ..db.base import Base


class Chore(Base):
    __tablename__ = "chores"

    id = Column(Integer, primary_key=True, autoincrement=True)
    chore_type = Column(String(25), nullable=False)
    done = Column(Boolean, nullable=False)
    user_id = Column(String(40), nullable=False)
    week_id = Column(String(7), nullable=False)
