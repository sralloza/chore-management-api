from ..db import tables
from ..models import ChoreType
from .base import CRUDBase

REAL_ID = "9ccce886-4fe2-42fc-872e-3afc2fa14ccf"
UPDATE_SQL = "UPDATE {table} SET {update} WHERE {id} = :id"


class CRUDChoreTypes(CRUDBase[ChoreType, ChoreType, ChoreType, str]):
    async def delete(self, *, id: str) -> None:
        # TODO: check if there is any chore with this chore type not completed
        # TODO: check if there is any ticket with this chore type unbalanced

        # TODO: delete all chores with this chore type
        # TODO: delete all tickets with this chore type
        return await super().delete(id=id)


chore_types = CRUDChoreTypes(ChoreType, tables.chore_type)
