from collections import namedtuple

WeeklyChore = namedtuple("WeeklyChore", "week_id chore tenants")


def parse_weekly_chores_res(res):
    data = res.json()
    chores = [x["chores"] for x in data]
    chores = [y for x in chores for y in x]

    return [
        WeeklyChore(x["week_id"], x["type"], tenants_to_str(x["assigned"]))
        for x in chores
    ]


def tenants_to_str(tenants):
    return ",".join([str(x) for x in tenants])


def parse_weekly_chores_res_table_str(res):
    res_json = res.json()
    if isinstance(res_json, list):
        chores = [x["chores"] for x in res_json]
        chores = [item for sublist in chores for item in sublist]
    else:
        chores = res_json["chores"]

    parsed = {}
    for chore in chores:
        if chore["week_id"] not in parsed:
            parsed[chore["week_id"]] = {}

        parsed[chore["week_id"]][chore["type"]] = tenants_to_str(chore["assigned"])

    data = []
    for week_id, chore_dict in parsed.items():
        result = {}
        result["week_id"] = week_id
        result.update(chore_dict)
        data.append(result)
    return data
