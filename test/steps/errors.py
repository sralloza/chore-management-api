from behave import *
from deepdiff import DeepDiff
from toolium.utils.dataset import map_param, replace_param


@then("the response contains the following validation errors")
def step_impl(context):
    context.table.require_columns(["location", "param", "msg"])
    errors = context.res.json()["errors"]
    for row in context.table:
        error = {
            "location": map_param(replace_param(row["location"])),
            "param": map_param(replace_param(row["param"])),
            "msg": map_param(replace_param(row["msg"])),
        }
        value = map_param(replace_param(row["value"]))
        if value != "[NONE]":
            error["value"] = value

        print(f"Expected error: {error}")
        if len(errors) == 1:
            diff = DeepDiff(error, errors[0])
            assert not diff, f"Unexpected validation error: {diff}"
        else:
            assert error in errors, f"Validation error {error} not found in {errors}"
