import i18n
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
    def throw_not_found_exception(self, lang: str, id: str):
        kwargs = dict(locale=lang, action="deactivated", week_id=id)
        detail = i18n.t("deactivated_weeks.confict_action", **kwargs)
        raise HTTPException(400, detail)

    def throw_conflict_exception(self, *, id: str, lang: str, action="deactivated"):
        action = i18n.t(f"actions.{action}", locale=lang)
        kwargs = dict(locale=lang, action=action, week_id=id)

        if "#" not in id:
            detail = i18n.t("deactivated_weeks.confict_action", **kwargs)
        else:
            week_id, user_id = id.split("#")
            kwargs.update(week_id=week_id, user_id=user_id)
            detail = i18n.t("deactivated_weeks.confict_action_user", **kwargs)
        raise HTTPException(409, detail)

    async def create(
        self, *, lang: str, obj_in: DeactivatedWeekCreate
    ) -> DeactivatedWeek:
        obj = DeactivatedWeek(**obj_in.dict(), id=obj_in.compute_id())
        return await super().create(lang=lang, obj_in=obj)

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
