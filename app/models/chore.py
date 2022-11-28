from pydantic import BaseModel, Field


class Chore(BaseModel):
    id: int
    chore_type: str = Field(max_length=25)
    done: bool = False
    user_id: str = Field(max_length=40)
    week_id: str = Field(max_length=7)
