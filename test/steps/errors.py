from collections import namedtuple

from behave import then
from deepdiff import DeepDiff

from common.utils import toolium_replace

ValidationError = namedtuple("ValidationError", ["location", "param", "msg"])


def parse_errors(errors) -> list[ValidationError]:
    parsed = []
    for error in errors:
        parsed.append(ValidationError(error["loc"][0], error["loc"][1], error["msg"]))
    return parsed


@then("the response contains the following validation errors")
def step_response_validation_errors(context):
    context.table.require_columns(["location", "param", "msg"])
    errors = parse_errors(context.res.json()["errors"])
    for row in context.table:
        error = ValidationError(
            toolium_replace(row["location"]),
            toolium_replace(row["param"]),
            toolium_replace(row["msg"]),
        )

        print(f"Expected error: {error}")
        errors_str = "".join([f"\n - {x}" for x in errors])
        print(f"Actual errors: {errors_str}")
        if len(errors) == 1:
            diff = DeepDiff(error, errors[0])
            assert not diff, f"Unexpected validation error: {diff}"
        else:
            assert error in errors, f"Validation error {error} not found in {errors}"
