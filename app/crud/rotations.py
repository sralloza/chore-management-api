from ..core.i18n import DEFAULT_LANG
from ..db import tables
from ..db.session import database
from ..models.rotations import Rotation
from .base import CRUDBase


class CRUDRotation(CRUDBase[Rotation, Rotation, Rotation, str]):
    async def get_last_rotation(self) -> Rotation | None:
        query = tables.rotations.select().order_by(self.table.c.week_id.desc())
        row = await database.fetch_one(query)
        return Rotation(**row) if row is not None else None

    async def delete(self, *, id: str) -> None:
        await self.get_or_404(lang=DEFAULT_LANG, id=id)
        await database.execute(self.table.delete().where(self.table.c.week_id == id))


rotation = CRUDRotation(Rotation, tables.rotations, "week_id")
