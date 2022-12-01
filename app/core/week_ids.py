from datetime import datetime, timedelta

from ..models.extras import WeekId


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
