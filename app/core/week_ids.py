from datetime import datetime, timedelta

from fastapi import HTTPException

from .. import crud
from ..models.extras import WeekId


def expand_week_id(week_id: str) -> str:
    if week_id == "next":
        week_id = get_next_week_id().week_id
    elif week_id == "current":
        week_id = get_current_week_id().week_id
    elif week_id == "last":
        week_id = get_last_week_id().week_id
    return week_id


async def validate_week_id_age(week_id: str, *, equals=False):
    last_rotation = await crud.rotation.get_last_rotation()
    if last_rotation is None:
        return

    if week_id < last_rotation.week_id:
        raise HTTPException(400, f"Chore types exist after week {week_id}")

    if equals is True and week_id == last_rotation.week_id:
        raise HTTPException(400, f"Chore types exist for week {week_id}")


def get_week_id(datetime: datetime) -> WeekId:
    week_id = datetime.isocalendar()[1]
    year = datetime.year
    return WeekId(week_id=f"{year}.{week_id:02d}")


def get_current_week_id() -> WeekId:
    return get_week_id(datetime.now())


def get_next_week_id() -> WeekId:
    return get_week_id(datetime.now() + timedelta(days=7))


def get_last_week_id() -> WeekId:
    return get_week_id(datetime.now() - timedelta(days=7))
