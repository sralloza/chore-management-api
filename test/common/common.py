from ast import literal_eval
import re
from itertools import zip_longest
from typing import List, Optional

from toolium.utils.dataset import replace_param as _tm_replace_param

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


def replace_param(context, param, infer_param_type=True):
    if not isinstance(param, str):
        return param

    match = re.match(r"\[(\d+)_LEN_STR\]", param)
    if match is not None:
        return "x" * int(match.group(1))
    if param == "[CURRENT_WEEK_ID]":
        return context.get("/week-id/current", silenced=True).json()["week_id"]
    if param == "[NEXT_WEEK_ID]":
        return context.get("/week-id/next", silenced=True).json()["week_id"]
    if param == "[LAST_WEEK_ID]":
        return context.get("/week-id/last", silenced=True).json()["week_id"]
    return _tm_replace_param(param, infer_param_type=infer_param_type)


def parse_table(
    table,
    *,
    mode: str = "literal",
    context=None,
    attrs: Optional[List[str]] = None,
):
    if mode not in ("literal", "replace_param", None):
        raise ValueError(f"Unknown mode {mode}")
    if mode == "replace_param" and context is None:
        raise ValueError("Context is required for replace_param mode")

    if not table:
        return []

    parser = get_parser(mode, context)

    result = []
    for row in table:
        parsed_row = dict(row.as_dict())
        if mode is not None:
            for key, value in parsed_row.items():
                if attrs is not None and key not in attrs:
                    continue
                try:
                    parsed_row[key] = parser(value)
                except Exception:
                    pass
        result.append(parsed_row)
    return result


def get_parser(mode, context=None):
    if mode == "literal":
        return literal_eval
    elif mode == "replace_param":
        return lambda x: replace_param(context, x)
    else:
        raise ValueError(f"Unknown mode {mode}")


def table_to_str(table):
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
            result += cell + "|"
        result += "\n"
    return result
