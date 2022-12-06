from fastapi import HTTPException

from ..db import tables
from ..models.chore import Chore, ChoreCreate
from .base import CRUDBase


def apply_filter(
    chore: Chore,
    chore_type_id: str | None = None,
    user_id: str | None = None,
    week_id: str | None = None,
    done: bool | None = None,
):
    if chore_type_id is not None and chore.chore_type != chore_type_id:
        return False
    if user_id is not None and chore.user_id != user_id:
        return False
    if week_id is not None and chore.week_id != week_id:
        return False
    if done is not None and chore.done != done:
        return False
    return True


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
                raise HTTPException(status_code=400, detail=detail)
        else:
            print(
                "Warning: No user_id provided to complete_chore, skipping user_id check"
            )

        for chore in chores:
            if user_id and chore.user_id != user_id:
                continue
            chore.done = True
            await self.update(id=chore.id, obj_in=chore)

    async def get_multi(
        self,
        *,
        skip: int = 0,
        limit: int = 100,
        chore_type_id: str | None = None,
        user_id: str | None = None,
        week_id: str | None = None,
        done: bool | None = None,
    ) -> list[Chore]:
        result = await super().get_multi(skip=skip, limit=limit)
        return [
            x for x in result if apply_filter(x, chore_type_id, user_id, week_id, done)
        ]


chores = CRUDChore(Chore, tables.chore)
