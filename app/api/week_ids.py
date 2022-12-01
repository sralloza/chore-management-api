from fastapi import APIRouter

from ..core.week_ids import get_current_week_id, get_last_week_id, get_next_week_id
from ..models.extras import WeekId

router = APIRouter()


@router.get("/current", response_model=WeekId, operation_id="getCurrentWeekId")
async def get_current():
    return get_current_week_id()


@router.get("/next", response_model=WeekId, operation_id="getNextWeekId")
async def get_next():
    return get_next_week_id()


@router.get("/last", response_model=WeekId, operation_id="getLastWeekId")
async def get_last():
    return get_last_week_id()
