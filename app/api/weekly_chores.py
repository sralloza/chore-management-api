from fastapi import APIRouter, Depends, Query

from ..core.params import LANG_HEADER, WEEK_ID_PATH
from ..core.week_ids import expand_week_id, validate_week_id_age
from ..core.weekly_chores import (
    create_weekly_chores,
    delete_weekly_chores_by_week_id,
    get_all_weekly_chores,
    get_weekly_chores_by_chores,
    get_weekly_chores_by_week_id,
)
from ..dependencies.auth import admin_required, user_required
from ..dependencies.pages import PaginationParams, pagination_params
from ..models.extras import Message
from ..models.weekly_chores import WeeklyChores

router = APIRouter()


@router.post(
    "/{week_id}",
    operation_id="createWeeklyChores",
    dependencies=[Depends(admin_required)],
    summary="Create weekly chores",
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
    lang: str = LANG_HEADER,
):
    """Create weekly chores for a specific week."""
    week_id = expand_week_id(week_id)
    await validate_week_id_age(week_id, lang)
    chores = await create_weekly_chores(
        week_id, lang=lang, dry_run=dry_run, force=force
    )
    return await get_weekly_chores_by_chores(chores, week_id)


@router.get(
    "/{week_id}",
    operation_id="getWeeklyChores",
    dependencies=[Depends(user_required)],
    summary="Get single weekly chores",
    response_model=WeeklyChores,
    responses={
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "Admin access required"},
        404: {"model": Message, "description": "Weekly chores not found"},
    },
)
async def get_weekly_chores(week_id: str = WEEK_ID_PATH, lang: str = LANG_HEADER):
    """Get weekly chores for a specific week."""
    week_id = expand_week_id(week_id)
    await validate_week_id_age(week_id, lang)
    return await get_weekly_chores_by_week_id(week_id, lang)


@router.get(
    "",
    dependencies=[Depends(user_required)],
    summary="List weekly chores",
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
    ),
    pagination: PaginationParams = Depends(pagination_params),
):
    """List all weekly chores."""
    return await get_all_weekly_chores(
        missing_only=missing_only,
        page=pagination.page,
        per_page=pagination.per_page,
    )


@router.delete(
    "/{week_id}",
    operation_id="deleteWeeklyChores",
    dependencies=[Depends(admin_required)],
    summary="Delete weekly chores",
    status_code=204,
    responses={
        400: {"model": Message, "description": "Weekly chores are partially completed"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "Admin access required"},
        404: {"model": Message, "description": "Weekly chores not found"},
    },
)
async def delete_weekly_chores(week_id: str = WEEK_ID_PATH, lang: str = LANG_HEADER):
    """Delete weekly chores for a specific week."""
    week_id = expand_week_id(week_id)
    await validate_week_id_age(week_id, lang)
    return await delete_weekly_chores_by_week_id(week_id, lang)
