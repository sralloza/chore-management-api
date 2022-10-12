from behave import *
from toolium.utils.dataset import map_param, replace_param


@then("the response contains the following validation errors")
def step_impl(context):
    context.table.require_columns(["location", "message"])
    errors = context.res.json()["errors"]
    for row in context.table:
        error = {
            "location": map_param(replace_param(row["location"])),
            "message": map_param(replace_param(row["message"])),
            "value": map_param(replace_param(row["value"])),
        }

        assert error in errors, f"Validation error {error} not found in {errors}"
