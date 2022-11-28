from pydantic import BaseModel, Field


class Ticket(BaseModel):
    id: int
    chore_type_id: str = Field(max_length=25)
    user_id: str = Field(max_length=40)
    tickets: int
