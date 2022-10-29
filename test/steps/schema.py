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
            f"Response code {code} not defined in operation {context.resource}"
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
        assert_that(context.res.text, matches_regexp(pattern))
        return

    # Special treatment for 409 responses
    if code == "409":
        pattern = r"\w+ already exists"
        assert_that(context.res.text, matches_regexp(pattern))
        return

    # Special treatment for 422 responses
    if code == "422":
        context.execute_steps(
            "Then the response body is validated against the json-schema"
        )
        return

    examples = get_examples(context)
    assert_that(context.res.json(), is_in(examples))


@then("the response body is validated against the json-schema")
def step_impl(context):
    context.execute_steps("Then the response status code is defined")

    schema = get_operation_schema(context)
    schemas_folder = Path(__file__).parent.parent / f"resources/schemas.json"

    resolver = RefResolver(referrer=schema, base_uri=schemas_folder.as_uri())

    api_response = context.res.json()
    extra_schemas = get_defined_schemas()
    schema["components"] = {"schemas": extra_schemas}

    validate_response(api_response, schema, resolver)


@then('the response body is validated against the json-schema "{schema}"')
def step_impl(context, schema):
    warnings.warn(
        "Deprecated step, use the step 'the response body is validated against the json-schema'",
        DeprecationWarning,
    )
    schema = Path(__file__).parent.parent / f"resources/schemas/{schema}.json"
    with open(schema) as f:
        json_schema = json.load(f)

    json_schema_dir = os.path.dirname(os.path.realpath(schema))
    resolver = RefResolver(
        referrer=json_schema, base_uri="file://" + json_schema_dir + "/"
    )

    api_response = context.res.json()
    validate_response(api_response, json_schema, resolver)
