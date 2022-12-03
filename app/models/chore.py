from pydantic import BaseModel, Field


class ChoreCreate(BaseModel):
    chore_type: str = Field(max_length=25)
    done: bool = False
    user_id: str = Field(max_length=40)
    week_id: str = Field(max_length=7)


class Chore(ChoreCreate):
    id: int
