from ast import literal_eval


def table_to_dict(table):
    if not table:
        return {}

    table.required_columns(["param_name", "param_value"])
    result = {}
    for row in table.rows:
        result[row["param_name"]] = row["param_value"]

    parsed = {}
    for k,v in result.items():
        parsed[k] = literal_eval(v)
    return parsed
