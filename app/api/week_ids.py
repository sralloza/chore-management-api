from fastapi import APIRouter

from ..core.week_ids import get_current_week_id, get_last_week_id, get_next_week_id
from ..models.extras import WeekId

router = APIRouter()


@router.get(
    "/current",
    operation_id="getCurrentWeekId",
    response_model=WeekId,
    summary="Get current week ID",
)
async def get_current():
    """Get current week ID."""
    return get_current_week_id()


@router.get(
    "/next",
    operation_id="getNextWeekId",
    response_model=WeekId,
    summary="Get next week ID",
)
async def get_next():
    """Get next week ID."""
    return get_next_week_id()


@router.get(
    "/last",
    operation_id="getLastWeekId",
    response_model=WeekId,
    summary="Get last week ID",
)
async def get_last():
    """Get last week ID."""
    return get_last_week_id()
