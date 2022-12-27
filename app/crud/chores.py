from datetime import datetime
from logging import getLogger

from fastapi import HTTPException

from ..db import tables
from ..models.chore import Chore, ChoreCreate
from .base import CRUDBase

logger = getLogger(__name__)


class CRUDChore(CRUDBase[Chore, ChoreCreate, Chore, int]):
    async def complete_chore(
        self, *, week_id: str, chore_type_id: str, user_id: str | None = None
    ):
        chores = await self.get_multi(week_id=week_id, chore_type_id=chore_type_id)
        if not chores:
            detail = (
                f"{self.model.__name__} with week_id={week_id} and"
                f" chore_type_id={chore_type_id} does not exist"
            )
            raise HTTPException(status_code=404, detail=detail)

        if all(x.done for x in chores):
            detail = (
                f"{self.model.__name__} with week_id={week_id} and"
                f" chore_type_id={chore_type_id} is already completed"
            )
            raise HTTPException(status_code=400, detail=detail)

        if user_id:
            user_ids = set(chore.user_id for chore in chores)
            if user_id not in user_ids:
                detail = (
                    f"You are not assigned to any chores of type {chore_type_id}"
                    f" for week {week_id}"
                )
                raise HTTPException(status_code=404, detail=detail)
        else:
            logger.warning(
                "No user_id provided to complete_chore, skipping user_id check"
            )

        for chore in chores:
            chore.done = True
            chore.completed_at = datetime.now()
            await self.update(id=chore.id, obj_in=chore)


chores = CRUDChore(Chore, tables.chore)
