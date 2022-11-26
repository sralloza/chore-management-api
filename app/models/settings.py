from sqlalchemy import Column, String

from ..db.base import Base


class Settings(Base):
    __tablename__ = "settings"

    primary_key = Column(String(36), primary_key=True)
    assignment_order = Column(String(2048), nullable=False)
    rotation_sign = Column(String(15), nullable=False)
