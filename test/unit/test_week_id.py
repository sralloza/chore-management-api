from datetime import datetime
from pathlib import Path

import pytest
from orjson import loads
from pydantic import BaseModel

from app.core.week_ids import get_week_id

TEST_DATA_FOLDER = Path(__file__).parent / "data/week-id"


class Interval(BaseModel):
    year: int
    month: int
    day_start: int
    day_end: int
    week_id: str


def get_test_data():
    intervals: list[Interval] = []
    for file in TEST_DATA_FOLDER.glob("*.json"):
        data = file.read_bytes()
        intervals.extend([Interval(**x) for x in loads(data)])

    test_data = []
    for interval in intervals:
        for day in range(interval.day_start, interval.day_end + 1):
            date = datetime(interval.year, interval.month, day)
            test_data.append((date, interval.week_id))

    test_data.sort(key=lambda x: x[0])
    return test_data


def get_id(item):
    if isinstance(item, datetime):
        return item.strftime("%Y-%m-%d")
    return item


data = get_test_data()


@pytest.mark.parametrize("date, week_id", data, ids=get_id)
def test_get_week_id(date: datetime, week_id: str):
    assert get_week_id(date).week_id == week_id
