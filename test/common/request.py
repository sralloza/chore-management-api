from toolium.utils.dataset import map_param, replace_param


def table_to_dict(table):
    if not table:
        return {}

    table.require_columns(["param_name", "param_value"])
    result = {}
    for row in table.rows:
        to_str = row.get("as_string", "fals").lower() == "true"
        value = row["param_value"]
        if value != "[NONE]":
            value = replace_param(value, infer_param_type=not to_str)
            value = map_param(value)
            result[row["param_name"]] = value

    return result
