from .. import crud
from ..db import tables
from ..models.chore_type import ChoreType
from .base import CRUDBase


class CRUDChoreTypes(CRUDBase[ChoreType, ChoreType, ChoreType, str]):
    async def create(self, *, obj_in: ChoreType) -> ChoreType:
        result = await super().create(obj_in=obj_in)
        await crud.tickets.create_tickets_for_new_chore_type(chore_type_id=result.id)
        return result

    async def delete(self, *, id: str) -> None:
        # TODO: check if there is any chore with this chore type not completed
        # TODO: check if there is any ticket with this chore type unbalanced

        # TODO: delete all chores with this chore type
        # TODO: delete all tickets with this chore type
        return await super().delete(id=id)


chore_types = CRUDChoreTypes(ChoreType, tables.chore_type)
