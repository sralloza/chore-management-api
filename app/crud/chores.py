from ..db import tables
from ..models.chore import Chore
from .base import CRUDBase


def apply_filter(
    chore: Chore,
    chore_type_id: int | None = None,
    user_id: int | None = None,
    week_id: str | None = None,
    done: bool | None = None,
):
    if chore_type_id and chore.chore_type != chore_type_id:
        return False
    if user_id and chore.user_id != user_id:
        return False
    if week_id and chore.week_id != week_id:
        return False
    if done and chore.done != done:
        return False
    return True


class CRUDChore(CRUDBase[Chore, Chore, Chore, int]):
    async def get_multi(
        self,
        *,
        skip: int = 0,
        limit: int = 100,
        chore_type_id: int | None = None,
        user_id: int | None = None,
        week_id: str | None = None,
        done: bool | None = None
    ) -> list[Chore]:
        result = await super().get_multi(skip=skip, limit=limit)
        return [
            x for x in result if apply_filter(x, chore_type_id, user_id, week_id, done)
        ]


chores = CRUDChore(Chore, tables.chore)
