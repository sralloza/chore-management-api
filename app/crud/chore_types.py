from fastapi import HTTPException

from .. import crud
from ..db import tables
from ..models.chore_type import ChoreType
from .base import CRUDBase


class CRUDChoreTypes(CRUDBase[ChoreType, ChoreType, ChoreType, str]):
    async def create(self, *, lang: str, obj_in: ChoreType) -> ChoreType:
        result = await super().create(lang=lang, obj_in=obj_in)
        await crud.tickets.create_tickets_for_new_chore_type(
            lang=lang, chore_type_id=result.id
        )
        return result

    async def delete(self, *, lang: str, id: str) -> None:
        chores = await crud.chores.get_multi(chore_type_id=id)
        if any((chore.done is False for chore in chores)):
            raise HTTPException(400, "Can't delete chore type with active chores")

        tickets = await crud.tickets.get_multi(chore_type_id=id)
        for ticket in tickets:
            if ticket.tickets != 0:
                raise HTTPException(400, "Chore type has unbalanced tickets")

        for chore in chores:
            await crud.chores.delete(lang=lang, id=chore.id)

        for ticket in tickets:
            await crud.tickets.delete(lang=lang, id=ticket.id)

        return await super().delete(lang=lang, id=id)


chore_types = CRUDChoreTypes(ChoreType, tables.chore_type)
