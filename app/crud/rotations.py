from ..db import tables
from ..db.session import database
from ..models.rotations import Rotation
from .base import CRUDBase


class CRUDRotation(CRUDBase[Rotation, Rotation, Rotation, str]):
    async def get_last_rotation(self) -> Rotation | None:
        query = tables.rotations.select().order_by(self.table.c.week_id.desc())
        row = await database.fetch_one(query)
        return Rotation(**row) if row is not None else None


rotation = CRUDRotation(Rotation, tables.rotations, "week_id")
