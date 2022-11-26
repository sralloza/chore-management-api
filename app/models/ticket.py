from sqlalchemy import Column, String, Integer

from ..db.base import Base


class Ticket(Base):
    __tablename__ = "tickets"

    id = Column(Integer, primary_key=True)
    chore_type_id = Column(String(25), nullable=False)
    user_id = Column(String(40), nullable=False)
    tickets = Column(Integer, nullable=False)
