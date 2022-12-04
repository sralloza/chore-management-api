from pydantic import BaseModel, Field
from datetime import datetime

class ChoreCreate(BaseModel):
    chore_type: str = Field(max_length=25)
    done: bool = False
    user_id: str = Field(max_length=40)
    week_id: str = Field(max_length=7)
    created_at: datetime = Field(default_factory=datetime.now)
    closed_at: datetime | None = None


class Chore(ChoreCreate):
    id: int
