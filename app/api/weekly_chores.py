from fastapi import APIRouter, Depends, Query

from ..core.constants import WEEK_ID_PATH
from ..core.week_ids import expand_week_id, validate_week_id_age
from ..core.weekly_chores import (
    create_weekly_chores,
    get_all_weekly_chores,
    get_weekly_chores_by_chores,
    get_weekly_chores_by_week_id,
)
from ..dependencies.auth import admin_required, user_required
from ..models.extras import Message
from ..models.weekly_chores import WeeklyChores

router = APIRouter()


@router.post(
    "/{week_id}",
    operation_id="createWeeklyChores",
    dependencies=[Depends(admin_required)],
    response_model=WeeklyChores,
    responses={
        400: {"model": Message, "description": "Bad request"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "Admin access required"},
        409: {"model": Message, "description": "Weekly chores already exist"},
    },
)
async def route_create_weekly_chores(
    week_id: str = WEEK_ID_PATH,
    dry_run: bool = Query(False, description="Simulate creation of weekly chores"),
    force: bool = Query(
        False, description="Force creation of weekly chores even if users have changed"
    ),
):
    week_id = expand_week_id(week_id)
    await validate_week_id_age(week_id)
    chores = await create_weekly_chores(week_id, dry_run=dry_run, force=force)
    return await get_weekly_chores_by_chores(chores, week_id)


@router.get(
    "/{week_id}",
    operation_id="getWeeklyChores",
    dependencies=[Depends(user_required)],
    response_model=WeeklyChores,
)
async def get_weekly_chores(week_id: str = WEEK_ID_PATH):
    week_id = expand_week_id(week_id)
    await validate_week_id_age(week_id)
    return await get_weekly_chores_by_week_id(week_id)


@router.get(
    "",
    dependencies=[Depends(user_required)],
    operation_id="listWeeklyChores",
    response_model=list[WeeklyChores],
    responses={
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
    },
)
async def list_weekly_chores(
    missing_only: bool = Query(
        False, description="Only show weekly chores that have missing chores"
    )
):
    return await get_all_weekly_chores(missing_only=missing_only)
