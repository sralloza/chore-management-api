from pydantic import BaseModel, Field

from .common import WEEK_ID_FIELD


class Message(BaseModel):
    message: str = Field(
        description="A human readable description of what the event represent",
        example="Human readable description of the error",
    )


class WeekId(BaseModel):
    week_id: str = WEEK_ID_FIELD
