from collections import defaultdict


def parse_weekly_chores_res_table_str(res):
    res_json = res.json()
    result = defaultdict(dict)
    if isinstance(res_json, list):
        for weekly_chore in res_json:
            _process_weekly_chore(result, weekly_chore)
    else:
        _process_weekly_chore(result, res_json)

    data = []
    for week_id, chore_dict in result.items():
        result = {}
        result["week_id"] = week_id
        result.update(chore_dict)
        data.append(result)
    return data


def _process_weekly_chore(result: defaultdict, weekly_chore: dict):
    week_id = weekly_chore["week_id"]
    chores = weekly_chore["chores"]
    for chore in chores:
        assigned = ",".join(chore["assigned_ids"])
        chore_type = chore["chore_type_id"]
        result[week_id][chore_type] = assigned
