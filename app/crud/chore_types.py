from fastapi import HTTPException

from .. import crud
from ..db import tables
from ..models.chore_type import ChoreType
from .base import CRUDBase


class CRUDChoreTypes(CRUDBase[ChoreType, ChoreType, ChoreType, str]):
    async def create(self, *, lang: str, obj_in: ChoreType) -> ChoreType:
        result = await super().create(lang=lang, obj_in=obj_in)
        await crud.tickets.create_tickets_for_new_chore_type(chore_type_id=result.id)
        return result

    async def delete(self, *, lang: str, id: str) -> None:
        chores = await crud.chores.get_multi(chore_type_id=id)
        if any((chore.done is False for chore in chores)):
            raise HTTPException(400, "Can't delete chore type with active chores")

        # TODO: check if there is any ticket with this chore type unbalanced

        for chore in chores:
            await crud.chores.delete(lang=lang, id=chore.id)

        # TODO: delete all tickets with this chore type
        return await super().delete(lang=lang, id=id)


chore_types = CRUDChoreTypes(ChoreType, tables.chore_type)
