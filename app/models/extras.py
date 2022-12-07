from pydantic import BaseModel, Field

from ..core.constants import WEEK_ID_REGEX


class Message(BaseModel):
    message: str = Field(
        description="A human readable description of what the event represent",
        example="Human readable description of the error",
    )


class WeekId(BaseModel):
    week_id: str = Field(regex=WEEK_ID_REGEX, example="2022.01")
