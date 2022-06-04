import re
from collections import namedtuple

import pandas as pd

WeeklyChore = namedtuple("WeeklyChore", "week_id chore flatmate")


def parse_weekly_chores_res(res):
    data = res.json()
    chores = [x["chores"] for x in data]
    chores = [y for x in chores for y in x]

    for chore in chores:
        print(chore)

    return [
        WeeklyChore(x["week_id"], x["type"], flatmates_to_str(x["assigned"]))
        for x in chores
    ]


def flatmates_to_str(flatmates):
    return ",".join([str(x) for x in flatmates])


def parse_weekly_chores_res_table_str(res):
    res_json = res.json()
    if isinstance(res_json, list):
        chores = [x["chores"] for x in res.json()]
        chores = [item for sublist in chores for item in sublist]
    else:
        chores = res_json["chores"]

    for chore in chores:
        print(chore)
        chore["assigned"] = flatmates_to_str(chore["assigned"])

    df = pd.DataFrame(chores)
    df2 = df.pivot(index="week_id", columns="type", values="assigned")
    df2.index.name = ""
    df_str = str(df2)
    df_str = re.sub("\n\\s+\n", "\n\n", df_str)
    return df_str
