from fastapi import HTTPException

from ..db import tables
from ..models.deactivated_weeks import DeactivatedWeek, DeactivatedWeekCreate
from .base import CRUDBase


def filter_week(
    week: DeactivatedWeek, user_id_assigned: bool | None, week_id: str | None
):
    if week_id is not None and week.week_id != week_id:
        return False
    if user_id_assigned is not None and (week.user_id is None) is user_id_assigned:
        return False
    return True


class CRUDDeactivatedWeeks(
    CRUDBase[DeactivatedWeek, DeactivatedWeek, DeactivatedWeek, str]
):
    def throw_not_found_exception(self, id: str):
        raise HTTPException(400, f"Week {id} is already deactivated")

    def throw_conflict_exception(self, id: str, action="deactivated"):
        if "#" not in id:
            detail = f"Week {id} is already {action}"
        else:
            week_id, user_id = id.split("#")
            detail = f"Week {week_id} is already {action} for user {user_id}"
        raise HTTPException(409, detail)

    async def create(self, *, obj_in: DeactivatedWeekCreate) -> DeactivatedWeek:
        obj = DeactivatedWeek(**obj_in.dict(), id=obj_in.compute_id())
        return await super().create(obj_in=obj)

    async def get_multi(
        self,
        *,
        skip: int = 0,
        limit: int = 100,
        user_id_assigned: bool | None = None,
        week_id: str | None = None,
    ) -> list[DeactivatedWeek]:
        data = await super().get_multi(skip=skip, limit=limit)
        return [x for x in data if filter_week(x, user_id_assigned, week_id)]


deactivated_weeks = CRUDDeactivatedWeeks(DeactivatedWeek, tables.deactivated_weeks)
