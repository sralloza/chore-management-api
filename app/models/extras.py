from pydantic import BaseModel, Field

from ..core.constants import WEEK_ID_REGEX


class Message(BaseModel):
    message: str


class WeekId(BaseModel):
    week_id: str = Field(regex=WEEK_ID_REGEX)
