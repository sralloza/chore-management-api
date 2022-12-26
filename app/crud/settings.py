from fastapi.exceptions import RequestValidationError
from pydantic.error_wrappers import ErrorWrapper
from pydantic.errors import PydanticValueError

from .. import crud
from ..db import tables
from ..db.session import database
from ..models.settings import (
    RotationSign,
    Settings,
    SettingsCreate,
    SettingsIO,
    SettingsUpdate,
    SettingsUpdateIO,
)
from .base import CRUDBase

REAL_ID = "9ccce886-4fe2-42fc-872e-3afc2fa14ccf"


class InvalidAssigmentOrder(PydanticValueError):
    code = "value_error.invalid_assignment_order"
    msg_template = "assignment_order contains invalid user ids or is missing some"


class CRUDSettings(CRUDBase[Settings, SettingsCreate, SettingsUpdate, str]):
    async def get(self, **kwargs) -> Settings | None:
        return await super().get(id=REAL_ID)

    async def get_or_404(self, **kwargs) -> Settings:
        return await super().get_or_404(id=REAL_ID)

    async def get_multi(self, *, page: int = 1, per_page: int = 30) -> list[Settings]:
        raise NotImplementedError

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

    async def update(self, *, obj_in: SettingsUpdateIO) -> Settings:
        if obj_in.assignment_order is not None:
            users = await crud.user.get_multi(per_page=100)
            asked_user_ids = set(obj_in.assignment_order)
            existing_user_ids = set([x.id for x in users])
            if asked_user_ids != existing_user_ids:
                error = ErrorWrapper(
                    InvalidAssigmentOrder(), loc=("body", "assignment_order")
                )
                raise RequestValidationError(errors=[error])

        if not await self.get():
            await self.reset_assignment_order()

        update_data = obj_in.dict(exclude_unset=True)
        assignment_order = update_data.pop("assignment_order", None)
        if assignment_order:
            update_data["assignment_order"] = ",".join(assignment_order)
        real_obj_in = SettingsUpdate(**update_data)
        return await super().update(id=REAL_ID, obj_in=real_obj_in)

    @staticmethod
    def map_to_io(settings: Settings) -> SettingsIO:
        order = [x for x in settings.assignment_order.split(",") if x]
        return SettingsIO(
            rotation_sign=settings.rotation_sign,
            assignment_order=order,
        )


settings = CRUDSettings(Settings, tables.settings)
