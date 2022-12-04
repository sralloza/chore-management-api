from datetime import datetime

from pydantic import BaseModel, Field


class ChoreCreate(BaseModel):
    chore_type: str = Field(max_length=25)
    done: bool = False
    user_id: str = Field(max_length=40)
    week_id: str = Field(max_length=7)
    created_at: datetime = Field(default_factory=datetime.now)
    # Issue with pydantic creating a schema of a nullable field
    # https://github.com/pydantic/pydantic/issues/4111
    # https://github.com/pydantic/pydantic/pull/1611
    closed_at: datetime | None = None


class Chore(ChoreCreate):
    id: int
