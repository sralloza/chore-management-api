from pydantic import BaseModel, Field


class TicketCreate(BaseModel):
    chore_type_id: str = Field(min_length=1, max_length=25, regex="^[a-z-]+$")
    user_id: str = Field(max_length=40)
    tickets: int


class Ticket(TicketCreate):
    id: int


class GroupedTicket(BaseModel):
    id: str = Field(min_length=1, max_length=25, regex="^[a-z-]+$")
    name: str = Field(min_length=1, max_length=50)
    description: str = Field(min_length=1, max_length=255)
    tickets_by_user_id: dict[str, int]
    tickets_by_user_name: dict[str, int]
