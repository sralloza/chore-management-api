import json
import os
import re
from ast import literal_eval
from pathlib import Path

from behave import *
from jsonschema import FormatChecker, RefResolver, ValidationError, validate

from common import *


# todo: remove when and given steps
@when('the response status code is "{code:d}"')
@given('the response status code is "{code:d}"')
@then('the response status code is "{code:d}"')
@then('all the response status codes are "{code:d}"')
def step_impl(context, code):
    errors = []
    res_list = context.res_list or [context.res]
    for res in res_list:
        actual = res.status_code
        if actual != code:
            path = get_path_from_res(res)
            msg = f"- [{path}] expected status code {code}, got {actual}\n    >>>> {res.text}"
            errors.append(msg)

    assert_not_errors(errors)


@step("the response body is a valid json")
def step_impl(context):
    try:
        json.loads(context.res.text)
    except ValueError as exc:
        assert False, f"Response body is not a valid json ({exc})"


@step("the {header} header is in the response")
def step_impl(context, header):
    msg = f"Header {header} is not present in the response.\nHEADERS: {context.api_response.headers}"
    assert context.api_response.headers.getlist(header), msg


@step('the HTTP status code should be in "{status_list}"')
def step_impl(context, status_list):
    msg = 'HTTP status code should be in "{}", but it is "{}"\n  >>>> {}"'
    status_list = literal_eval(status_list)
    status = context.res.status_code
    assert status in status_list, msg.format(status_list, status, context.res.text)


@step('the error message contains "{message}"')
def step_impl(context, message):
    assert "message" in context.res.json(), "No error message in response"
    actual = context.res.json()["message"]
    error_msg = f'The error message should contain "{message}", but it is "{actual}"'
    assert re.search(message, actual), error_msg


@then('one of messages in the errors array is "{message}"')
@then("one of messages in the errors array is the following")
def step_impl(context, message=None):
    message = message or context.text
    assert "errors" in context.res.json(), "No errors array in response"
    errors_array = [x["defaultMessage"] for x in context.res.json()["errors"]]
    error_msg = f'One of the messages in the errors array should contain "{message}" ({errors_array})'
    assert message in errors_array, error_msg


@step("the error message is the following")
@step('the error message is "{message}"')
def step_impl(context, message=None):
    message = message or context.text
    assert "message" in context.res.json(), "No error message in response"
    actual = context.res.json()["message"]

    msg = 'The error message should be "{}", but it is "{}"'
    assert actual == message, msg.format(message, actual)


# todo: remove when step
@when('the response body is validated against the json-schema "{schema}"')
@then('the response body is validated against the json-schema "{schema}"')
@then('all the response bodies are validated against the json-schema "{schema}"')
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
            msg = f"- ValidationError on response #{i}: {exc.message}"
            errors.append(msg)

    assert_not_errors(errors)


@step('I save the "{attr}" attribute of the response as "{dest}"')
def step_impl(context, attr, dest):
    setattr(context, dest, context.res.json()[attr])
