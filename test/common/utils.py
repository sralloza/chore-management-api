from ast import literal_eval
from itertools import zip_longest
from typing import List, Optional

from toolium.utils.dataset import replace_param

URL = "http://localhost:8080"
VERSIONED_URL_TEMPLATE = URL + "/v{version}"


def assert_not_errors(errors):
    assert not errors, "\n" + "\n".join(errors) + "\n\n"


def get_path_from_res(res):
    return res.request.url.replace(URL, "")


def assert_arrays_equal(expected, actual):
    errors = []
    if len(expected) != len(actual):
        errors.append(f"- Expected {len(expected)} items, got {len(actual)}")

    for i, (e, a) in enumerate(zip_longest(expected, actual)):
        if e != a:
            errors.append(f"- Position {i} not equal: {e} != {a}")
    assert_not_errors(errors)


def assert_arrays_not_contain(expected, actual):
    errors = []
    for i, element in enumerate(expected):
        if element in actual:
            errors.append(f"- Element {i} found in array ({actual})")
    assert_not_errors(errors)


def assert_has_text(context):
    assert context.text, "Step has no text"


def assert_has_table(context):
    assert context.table, "Step has no table"


def parse_table(
    table, *, mode: str = "literal", attrs: Optional[List[str]] = None, **kwargs
):
    if mode not in ("literal", "replace_param", None):
        raise ValueError(f"Unknown mode {mode}")

    if not table:
        return []

    parser = get_parser(mode)

    result = []
    for row in table:
        parsed_row = dict(row.as_dict())
        if mode is not None:
            for key, value in parsed_row.items():
                if attrs is not None and key not in attrs:
                    continue
                try:
                    parsed_row[key] = parser(value, **kwargs)
                except Exception:
                    pass
        result.append(parsed_row)
    return result


def get_parser(mode):
    if mode == "literal":
        return literal_eval
    elif mode == "replace_param":
        return replace_param
    else:
        raise ValueError(f"Unknown mode {mode}")


def list_of_dicts_to_table_str(list_of_dicts):
    if not list_of_dicts:
        return ""

    headlines = list(list_of_dicts[0].keys())
    result = "|"
    for heading in headlines:
        result += heading + "|"
    result += "\n"

    for line in list_of_dicts:
        result += "|"
        for key in headlines:
            result += f"{line[key]}|"
        result += "\n"

    return result


def table_to_str(table, replace=False, infer=True):
    if not table:
        return ""

    result = ""
    if table.headings:
        result = "|"
    for heading in table.headings:
        result += heading + "|"
    result += "\n"
    for row in table.rows:
        if row.cells:
            result += "|"
        for cell in row.cells:
            if replace:
                cell = replace_param(cell, infer_param_type=infer)
            result += cell + "|"
        result += "\n"
    return result


def replace_nested_ob(obj):
    if isinstance(obj, list):
        for item in obj:
            replace_nested_ob(item)
    else:
        _replace_obj(obj)


def _replace_obj(obj: dict):
    for key, value in obj.items():
        if isinstance(value, dict):
            _replace_obj(value)
        elif isinstance(value, list):
            for i, item in enumerate(value):
                if isinstance(item, dict):
                    _replace_obj(item)
                else:
                    obj[key][i] = replace_param(item)
        else:
            obj[key] = replace_param(value)


def payload_to_table_format(params):
    table = []
    for key, value in params.items():
        row = {}
        row["param_name"] = key
        row["param_value"] = value
        table.append(row)
    return list_of_dicts_to_table_str(table)
