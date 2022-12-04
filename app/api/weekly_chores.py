from fastapi import APIRouter, Depends, Path

from ..core.constants import WEEK_ID_EXPANDED_REGEX
from ..core.week_ids import expand_week_id, validate_week_id_age
from ..core.weekly_chores import (
    create_next_weekly_chores,
    get_all_weekly_chores,
    get_weekly_chores_by_week_id,
)
from ..dependencies.auth import admin_required

router = APIRouter()


@router.post(
    "/{week_id}",
    operation_id="createWeeklyChores",
    dependencies=[Depends(admin_required)],
)
async def create_weekly_chores(
    week_id: str = Path(...,
    regex=WEEK_ID_EXPANDED_REGEX)
):
    week_id = expand_week_id(week_id)
    await validate_week_id_age(week_id)
    await create_next_weekly_chores(week_id)
    return await get_weekly_chores_by_week_id(week_id)


@router.get("", operation_id="listWeeklyChores")
async def list_weekly_chores():
    return await get_all_weekly_chores()
