from ..db import tables
from ..models import ChoreType
from .base import CRUDBase

REAL_ID = "9ccce886-4fe2-42fc-872e-3afc2fa14ccf"
UPDATE_SQL = "UPDATE {table} SET {update} WHERE {id} = :id"


class CRUDChoreTypes(CRUDBase[ChoreType, ChoreType, ChoreType, str]):
    pass


chore_types = CRUDChoreTypes(ChoreType, tables.chore_type)
