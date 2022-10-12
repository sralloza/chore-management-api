import json
import os
from pathlib import Path

from behave import *
from jsonschema import RefResolver

from common.openapi import (
    get_current_operation,
    get_defined_schemas,
    get_openapi,
    validate_response,
)


@then("the response status code is defined")
def step_impl(context):
    code = context.res.status_code
    operation = get_current_operation(context)

    valid_codes = list(operation["responses"].keys())

    if code not in valid_codes:
        raise ValueError(
            f"Response code {code} not defined in operation {context.resource}"
            f" (defined: {valid_codes})"
        )


@then("the response body is validated against the json-schema")
def step_impl(context):
    context.execute_steps("Then the response status code is defined")
    data = get_openapi()
    operation = get_current_operation(context)

    valid_codes = (200, 201, 202, 204)
    schema = None
    for code in valid_codes:
        if code in operation["responses"]:
            schema = operation["responses"][code]
            if "$ref" in schema:
                schema = data["components"]["responses"][schema["$ref"].split("/")[-1]]
            schema = schema["content"]["application/json"]["schema"]
            break
    else:
        assert False, f"No schema found for operation {context.resource}"

    if "$ref" not in schema:
        raise ValueError(f"Schema for operation {context.resource} is not a reference")

    schema_name = schema["$ref"].split("/")[-1].strip("#")
    real_schema = dict(data["components"]["schemas"][schema_name])

    schemas_folder = Path(__file__).parent.parent / f"resources/schemas.json"

    resolver = RefResolver(referrer=real_schema, base_uri=schemas_folder.as_uri())

    api_response = context.res.json()
    extra_schemas = get_defined_schemas()
    real_schema["components"] = {"schemas": extra_schemas}

    validate_response(api_response, real_schema, resolver)


@then('the response body is validated against the json-schema "{schema}"')
def step_impl(context, schema):
    schema = Path(__file__).parent.parent / f"resources/schemas/{schema}.json"
    with open(schema) as f:
        json_schema = json.load(f)

    json_schema_dir = os.path.dirname(os.path.realpath(schema))
    resolver = RefResolver(
        referrer=json_schema, base_uri="file://" + json_schema_dir + "/"
    )

    api_response = context.res.json()
    validate_response(api_response, json_schema, resolver)
