from fastapi import APIRouter, Depends

from .. import crud
from ..core.params import LANG_HEADER
from ..dependencies.auth import user_required
from ..models.extras import Message
from ..models.ticket import GroupedTicket

router = APIRouter()


@router.get(
    "",
    response_model=list[GroupedTicket],
    operation_id="listTickets",
    dependencies=[Depends(user_required)],
    responses={
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
    },
)
async def get_tickets(lang: str = LANG_HEADER):
    return await crud.tickets.get_grouped_tickets(lang=lang)
