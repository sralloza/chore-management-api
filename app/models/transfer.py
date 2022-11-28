from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field


class Transfer(BaseModel):
    id: int
    accepted: bool = False
    chore_type_id: str = Field(max_length=25)
    completed: bool = False
    user_id_from: str = Field(max_length=40)
    user_id_to: str = Field(max_length=40)
    created_at: datetime = Field(default_factory=datetime.now)
    closed_at: Optional[datetime]
    week_id: str = Field(max_length=7)
