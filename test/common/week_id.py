from datetime import datetime, timedelta

def assert_week_id_equals(expected, actual):
    assert actual == expected, f"Expected weekId {expected}, got {actual}"

def get_week_id_from_res(res):
    res_json = res.json()
    assert "week_id" in res_json

    return res_json["week_id"]

def calculate_current_week_id():
    return _calculate_week_id(datetime.now())


def calculate_next_week_id():
    date = datetime.now() + timedelta(days=7)
    return _calculate_week_id(date)


def calculate_last_week_id():
    date = datetime.now() - timedelta(days=7)
    return _calculate_week_id(date)


def _calculate_week_id(datetime):
    week_num = datetime.isocalendar()[1]
    return f"{datetime.year}.{week_num}"
