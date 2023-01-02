from datetime import datetime

from pydantic import BaseModel, Field

from .common import (
    CHORE_TYPE_ID_FIELD,
    USER_ID_FIELD,
    WEEK_ID_EXTENDED_FIELD,
    WEEK_ID_FIELD,
)


class Transfer(BaseModel):
    id: int
    accepted: bool | None = None
    chore_type_id: str = CHORE_TYPE_ID_FIELD
    completed: bool = False
    user_id_from: str = USER_ID_FIELD
    user_id_to: str = USER_ID_FIELD
    created_at: datetime = Field(default_factory=datetime.now)
    completed_at: datetime | None
    week_id: str = WEEK_ID_FIELD


class TransferCreate(BaseModel):
    chore_type_id: str
    user_id_from: str
    user_id_to: str
    week_id: str = WEEK_ID_EXTENDED_FIELD


class TransferCreateInner(TransferCreate):
    accepted: bool | None = None
    completed: bool = False
    created_at: datetime = Field(default_factory=datetime.now)
