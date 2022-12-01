from .. import crud
from ..db import tables
from ..models.ticket import GroupedTicket, Ticket, TicketCreate
from .base import CRUDBase


async def mapper(db_tickets: list[Ticket]) -> list[GroupedTicket]:
    """Map the database tickets to the GroupedTicket model."""
    grouped_tickets = {}
    if not db_tickets:
        chore_types = await crud.chore_types.get_multi()
        return [
            GroupedTicket(
                id=chore_type.id,
                name=chore_type.name,
                description=chore_type.description,
                tickets_by_user_id={},
                tickets_by_user_name={},
            )
            for chore_type in chore_types
        ]

    for db_ticket in db_tickets:
        if db_ticket.chore_type_id not in grouped_tickets:
            chore_type = await crud.chore_types.get_or_404(db_ticket.chore_type_id)
            grouped_tickets[db_ticket.chore_type_id] = {
                "id": db_ticket.chore_type_id,
                "name": chore_type.name,
                "description": chore_type.description,
                "tickets_by_user_id": {},
                "tickets_by_user_name": {},
            }
        user = await crud.user.get_or_404(db_ticket.user_id)
        grouped_tickets[db_ticket.chore_type_id]["tickets_by_user_id"][
            db_ticket.user_id
        ] = db_ticket.tickets
        grouped_tickets[db_ticket.chore_type_id]["tickets_by_user_name"][
            user.username
        ] = db_ticket.tickets
    return [
        GroupedTicket(**grouped_ticket) for grouped_ticket in grouped_tickets.values()
    ]


class CRUDTickets(CRUDBase[Ticket, TicketCreate, Ticket, int]):
    async def get_grouped_tickets(self) -> list[GroupedTicket]:
        db_tickets = await self.get_multi()
        return await mapper(db_tickets)

    async def create_tickets_for_new_user(self, *, user_id: str):
        db_chore_types = await crud.chore_types.get_multi()
        for db_chore_type in db_chore_types:
            await self.create(
                obj_in=TicketCreate(
                    chore_type_id=db_chore_type.id,
                    user_id=user_id,
                    tickets=0,
                )
            )

    async def create_tickets_for_new_chore_type(self, *, chore_type_id: str):
        db_users = await crud.user.get_multi()
        for db_user in db_users:
            await self.create(
                obj_in=TicketCreate(
                    chore_type_id=chore_type_id,
                    user_id=db_user.id,
                    tickets=0,
                )
            )


tickets = CRUDTickets(Ticket, tables.ticket)
