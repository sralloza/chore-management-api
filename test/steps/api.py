import json
import os
from pathlib import Path

from behave import step
from jsonschema import FormatChecker, RefResolver, ValidationError, validate


@step('the response status code is "{code:d}"')
@step('all the response status codes are "{code:d}"')
def step_impl(context, code):
    errors = []
    res_list = context.res_list or [context.res]
    for res in res_list:
        actual = res.status_code
        if actual != code:
            msg = f"- Expected status code {code}, got {actual}"
            errors.append(msg)

    assert not errors, "\n" + "\n".join(errors)


@step('the response body is validated against the json-schema "{schema}"')
@step('the response body is validated against the json-schema "{schema}"')
def step_impl(context, schema):
    schema = Path(__file__).parent.parent / f"settings/schemas/{schema}.json"
    with open(schema) as f:
        json_schema = json.load(f)

    json_schema_dir = os.path.dirname(os.path.realpath(schema))
    resolver = RefResolver(
        referrer=json_schema, base_uri="file://" + json_schema_dir + "/"
    )

    res_list = context.res_list or [context.res]
    errors = []
    for i, res in enumerate(res_list):
        api_response = res.json()

        try:
            validate(
                api_response,
                json_schema,
                resolver=resolver,
                format_checker=FormatChecker(),
            )
        except ValidationError as exc:
            msg = f"- ValidationError on response #{i} {exc.message}"
            errors.append(msg)

    assert not errors, "\n" + "\n".join(errors)
