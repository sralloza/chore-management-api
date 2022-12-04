from datetime import datetime, timedelta

from ..models.extras import WeekId


def expand_week_id(week_id: str) -> str:
    if week_id == "next":
        week_id = get_next_week_id().week_id
    elif week_id == "current":
        week_id = get_current_week_id().week_id
    elif week_id == "last":
        week_id = get_last_week_id().week_id
    return week_id


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
