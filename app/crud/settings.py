from .. import crud
from ..db import tables
from ..db.db import database
from ..models import RotationSign, Settings, SettingsCreate, SettingsIO, SettingsUpdate
from .base import CRUDBase

REAL_ID = "9ccce886-4fe2-42fc-872e-3afc2fa14ccf"
UPDATE_SQL = "UPDATE {table} SET {update} WHERE {id} = :id"


class CRUDSettings(CRUDBase[Settings, SettingsCreate, SettingsUpdate, str]):
    async def get(self, **kwargs) -> Settings | None:
        return await super().get(id=REAL_ID)

    async def get_or_404(self, **kwargs) -> Settings:
        return await super().get_or_404(id=REAL_ID)

    async def reset_assignment_order(self):
        settings = await self.get()
        user_ids = await crud.user.get_user_ids()

        if not settings:
            await super().create(
                obj_in=SettingsCreate(
                    id=REAL_ID,
                    rotation_sign=RotationSign.positive,
                    assignment_order=",".join(user_ids),
                )
            )
            return

        values = dict(assignment_order=",".join(user_ids))
        query = self.table.update().where(self.table.c.id == REAL_ID).values(values)
        await database.execute(query)

    async def update(self, *, obj_in: SettingsUpdate) -> Settings:
        return await super().update(id=REAL_ID, obj_in=obj_in)

    @staticmethod
    def map_to_io(settings: Settings) -> SettingsIO:
        return SettingsIO(
            rotation_sign=settings.rotation_sign,
            assignment_order=settings.assignment_order.split(","),
        )


settings = CRUDSettings(Settings, tables.settings)