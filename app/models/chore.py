from datetime import datetime

from pydantic import BaseModel, Field

from .common import CHORE_TYPE_ID_FIELD, USER_ID_FIELD, WEEK_ID_FIELD


class ChoreCreate(BaseModel):
    chore_type_id: str = CHORE_TYPE_ID_FIELD
    done: bool = False
    user_id: str = USER_ID_FIELD
    week_id: str = WEEK_ID_FIELD
    created_at: datetime = Field(default_factory=datetime.now)
    # Issue with pydantic creating a schema of a nullable field
    # https://github.com/pydantic/pydantic/issues/4111
    # https://github.com/pydantic/pydantic/pull/1611
    completed_at: datetime | None = None


class Chore(ChoreCreate):
    id: int
