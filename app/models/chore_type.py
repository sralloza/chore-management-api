from sqlalchemy import Column, String

from ..db.base import Base


class ChoreType(Base):
    __tablename__ = "chore_types"

    id = Column(String(25), primary_key=True)
    name = Column(String(50), nullable=False)
    description = Column(String(255), nullable=False)
