import json
import os
import warnings
from pathlib import Path

from behave import *
from hamcrest import *
from jsonschema import RefResolver

from common.openapi import *


@then("the response status code is defined")
def step_impl(context):
    code = str(context.res.status_code)
    operation = get_current_operation(context)

    valid_codes = list(operation["responses"].keys())

    if code not in valid_codes:
        raise ValueError(
            f"Response code {code} not defined in operation {context.operation_id}"
            f" (defined: {valid_codes})"
        )


@then("the response error message is defined")
def step_impl(context):
    code = str(context.res.status_code)
    if code[0] not in ("4", "5"):
        raise ValueError(f"Response code {code} is not an error code")

    # Special treatment for 404 responses
    if code == "404":
        pattern = r"\w+ not found: \w"
        assert_that(context.res.text, matches_regexp(pattern), "Must match 404 pattern")
        return

    # Special treatment for 409 responses
    if code == "409":
        pattern = r"\w+ already exists"
        assert_that(context.res.text, matches_regexp(pattern), "Must match 409 pattern")
        return

    # Special treatment for 422 responses
    if code == "422":
        context.execute_steps(
            "Then the response body is validated against the json-schema"
        )
        return

    examples = get_examples(context)
    assert_that(
        context.res.json(), is_in(examples), "Error response must be in examples"
    )


@then("the response body is validated against the json-schema")
def step_impl(context):
    context.execute_steps("Then the response status code is defined")

    schema = get_operation_schema(context)
    resolver = RefResolver(referrer=schema, base_uri="file:///")

    api_response = context.res.json()
    extra_schemas = get_defined_schemas()

    schema["$schema"] = "https://json-schema.org/draft-07/schema"
    schema["components"] = {"schemas": extra_schemas}

    validate_response(api_response, schema, resolver)
