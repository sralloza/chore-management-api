from pydantic import BaseModel, Field


class Message(BaseModel):
    message: str


class WeekId(BaseModel):
    week_id: str = Field(regex=r"^\d{4}\.\d{2}$")
