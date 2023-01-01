from dotty_dict import dotty
from toolium.utils.dataset import map_param, replace_param


def table_to_dict(table, col_param="param_name", col_value="param_value"):
    if not table:
        return {}

    table.require_columns([col_param, col_value])
    result = dotty()
    for row in table.rows:
        to_str = row.get("as_string", "").lower() == "true"
        value = row[col_value]
        key = row[col_param]
        if value != "[NONE]":
            value = replace_param(value, infer_param_type=not to_str)
            value = map_param(value)
            result[key] = value

    return result.to_dict()
