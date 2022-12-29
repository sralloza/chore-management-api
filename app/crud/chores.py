from datetime import datetime

import i18n
from fastapi import HTTPException

from ..db import tables
from ..models.chore import Chore, ChoreCreate
from .base import CRUDBase


class CRUDChore(CRUDBase[Chore, ChoreCreate, Chore, int]):
    def throw_already_completed_exception(
        self, *, lang: str, week_id: str, chore_type_id: str
    ):
        detail = i18n.t(
            "crud.bad_request.already_completed",
            locale=lang,
            model_name=self.get_model_name(lang=lang),
            week_id=week_id,
            chore_type_id=chore_type_id,
        )
        raise HTTPException(status_code=400, detail=detail)

    def throw_not_chores_found_exception(
        self, *, lang: str, week_id: str, chore_type_id: str
    ):
        detail = i18n.t(
            "crud.not_found.no_chores",
            locale=lang,
            chore_type_id=chore_type_id,
            week_id=week_id,
        )
        raise HTTPException(status_code=404, detail=detail)

    async def complete_chore(
        self, *, lang: str, week_id: str, chore_type_id: str, user_id: str | None
    ):
        chores = await self.get_multi(week_id=week_id, chore_type_id=chore_type_id)
        if not chores:
            detail = (
                f"{self.model.__name__} with week_id={week_id} and"
                f" chore_type_id={chore_type_id} does not exist"
            )
            raise HTTPException(status_code=404, detail=detail)

        if all(x.done for x in chores):
            self.throw_already_completed_exception(
                lang=lang, week_id=week_id, chore_type_id=chore_type_id
            )

        if user_id is not None:
            user_ids = set(chore.user_id for chore in chores)
            if user_id not in user_ids:
                self.throw_not_chores_found_exception(
                    lang=lang, week_id=week_id, chore_type_id=chore_type_id
                )

        for chore in chores:
            chore.done = True
            chore.completed_at = datetime.now()
            await self.update(id=chore.id, lang=lang, obj_in=chore)


chores = CRUDChore(Chore, tables.chore)
