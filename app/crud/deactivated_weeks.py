from fastapi import HTTPException

from ..core.i18n import DEFAULT_LANG
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
        return await super().create(lang=DEFAULT_LANG, obj_in=obj)

    async def get_multi(
        self,
        *,
        page: int = 1,
        per_page: int = 30,
        assigned_to_user: bool | None = None,
        **kwargs,
    ) -> list[DeactivatedWeek]:
        query_mod = None
        if assigned_to_user is not None:

            def query_mod(query):
                if assigned_to_user:
                    return query.where(self.table.c.user_id is not None)
                return query.where(self.table.c.user_id is None)

        return await super().get_multi(
            page=page, per_page=per_page, query_mod=query_mod, **kwargs
        )


deactivated_weeks = CRUDDeactivatedWeeks(DeactivatedWeek, tables.deactivated_weeks)
