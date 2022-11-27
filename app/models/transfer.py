from datetime import datetime
from typing import Optional

from sqlmodel import Field, SQLModel


class Transfer(SQLModel, table=True):
    id: int = Field(primary_key=True)
    accepted: bool = Field(default=False)
    chore_type_id: str = Field(max_length=25)
    completed: bool = Field(default=False)
    user_id_from: str = Field(max_length=40)
    user_id_to: str = Field(max_length=40)
    created_at: datetime = Field(default_factory=datetime.now)
    closed_at: Optional[datetime]
    week_id: str = Field(max_length=7)
