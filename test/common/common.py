import re

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

    for i, (e, a) in enumerate(zip(expected, actual)):
        if e != a:
            errors.append(f"- Position {i} not equal: {e} != {a}")
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
