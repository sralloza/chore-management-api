from fastapi import HTTPException

from ..db import tables
from ..models.deactivated_weeks import DeactivatedWeek, DeactivatedWeekCreate
from .base import CRUDBase


class CRUDDeactivatedWeeks(
    CRUDBase[DeactivatedWeek, DeactivatedWeek, DeactivatedWeek, str]
):
    template_409 = "Week {id} is already deactivated"

    def throw_404_exception(self, id: str):
        raise HTTPException(400, self.template_409.format(id=id))

    async def create(self, *, obj_in: DeactivatedWeekCreate) -> DeactivatedWeek:
        obj = DeactivatedWeek(**obj_in.dict(), id=obj_in.compute_id())
        return await super().create(obj_in=obj)


deactivated_weeks = CRUDDeactivatedWeeks(DeactivatedWeek, tables.deactivated_weeks)
