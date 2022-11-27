from behave import *
from deepdiff import DeepDiff
from collections import namedtuple
from common.utils import toolium_replace

ValidationError = namedtuple("ValidationError", ["location", "param", "msg"])

def parse_errors(errors):
    parsed = []
    for error in errors:
        parsed.append(ValidationError(
            error["loc"][0],
            error["loc"][1],
            error["msg"]
        ))
    return parsed

@then("the response contains the following validation errors")
def step_impl(context):
    context.table.require_columns(["location", "param", "msg"])
    errors = parse_errors(context.res.json()["errors"])
    for row in context.table:
        error = ValidationError(
            toolium_replace(row["location"]),
            toolium_replace(row["param"]),
            toolium_replace(row["msg"])
        )

        print(f"Expected error: {error}")
        if len(errors) == 1:
            diff = DeepDiff(error, errors[0])
            assert not diff, f"Unexpected validation error: {diff}"
        else:
            assert error in errors, f"Validation error {error} not found in {errors}"
