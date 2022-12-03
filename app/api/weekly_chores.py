from fastapi import APIRouter, Depends, Path

from ..core.weekly_chores import (
    create_next_weekly_chores,
    get_all_weekly_chores,
    get_weekly_chores_by_week_id,
)
from ..dependencies.auth import admin_required
from ..core.week_ids import get_current_week_id, get_last_week_id, get_next_week_id

router = APIRouter()


@router.post(
    "/{week_id}",
    operation_id="createWeeklyChores",
    dependencies=[Depends(admin_required)],
)
async def create_weekly_chores(
    week_id: str = Path(..., regex=r"^(\d{4}\.\d{2}|next|current|last)$")
):
    if week_id == "next":
        week_id = get_next_week_id().week_id
    elif week_id == "current":
        week_id = get_current_week_id().week_id
    elif week_id == "last":
        week_id = get_last_week_id().week_id

    await create_next_weekly_chores(week_id)
    return await get_weekly_chores_by_week_id(week_id)


@router.get("", operation_id="listWeeklyChores")
async def list_weekly_chores():
    return await get_all_weekly_chores()
