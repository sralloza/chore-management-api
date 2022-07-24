from toolium.utils.dataset import replace_param


def table_to_dict(table):
    if not table:
        return {}

    table.require_columns(["param_name", "param_value"])
    result = {}
    for row in table.rows:
        result[row["param_name"]] = replace_param(row["param_value"])

    return result
