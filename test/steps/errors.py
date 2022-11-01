from behave import *
from deepdiff import DeepDiff

from common.utils import toolium_replace


@then("the response contains the following validation errors")
def step_impl(context):
    context.table.require_columns(["location", "param", "msg"])
    errors = context.res.json()["errors"]
    for row in context.table:
        error = {
            "location": toolium_replace(row["location"]),
            "param": toolium_replace(row["param"]),
            "msg": toolium_replace(row["msg"]),
        }
        value = toolium_replace(row["value"]) if "value" in row.headings else "[NONE]"
        if value != "[NONE]":
            error["value"] = value

        print(f"Expected error: {error}")
        if len(errors) == 1:
            diff = DeepDiff(error, errors[0])
            assert not diff, f"Unexpected validation error: {diff}"
        else:
            assert error in errors, f"Validation error {error} not found in {errors}"
