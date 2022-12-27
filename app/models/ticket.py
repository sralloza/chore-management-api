from pydantic import BaseModel

from .common import (
    CHORE_TYPE_DESCRIPTION_FIELD,
    CHORE_TYPE_ID_FIELD,
    CHORE_TYPE_NAME_FIELD,
    USER_ID_FIELD,
)


class TicketCreate(BaseModel):
    chore_type_id: str = CHORE_TYPE_ID_FIELD
    user_id: str = USER_ID_FIELD
    tickets: int


class Ticket(TicketCreate):
    id: int


class GroupedTicket(BaseModel):
    id: str = CHORE_TYPE_ID_FIELD
    name: str = CHORE_TYPE_NAME_FIELD
    description: str = CHORE_TYPE_DESCRIPTION_FIELD
    tickets_by_user_id: dict[str, int]
    tickets_by_user_name: dict[str, int]
