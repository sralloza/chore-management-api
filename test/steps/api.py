import json
import os
import re
from datetime import datetime
from pathlib import Path

from behave import *
from dateutil.parser import parse
from hamcrest import *
from jsonschema import FormatChecker, RefResolver, ValidationError, validate

from common.utils import *


@then('the response status code is "{code:d}"')
def step_impl(context, code):
    actual = context.res.status_code
    assert_that(actual, equal_to(code), f"Expected status code {code}, got {actual}")


@step("the response body is a valid json")
def step_impl(context):
    try:
        json.loads(context.res.text)
    except ValueError as exc:
        assert False, f"Response body is not a valid json ({exc})"


@step("the {header} header is in the response")
def step_impl(context, header):
    msg = f"Header {header} is not present in the response.\nHEADERS: {context.res.headers}"
    assert context.res.headers.getlist(header), msg


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

    try:
        validate(
            api_response,
            json_schema,
            resolver=resolver,
            format_checker=FormatChecker(),
        )
    except ValidationError as exc:
        msg = f"- Json Schema ValidationError: {exc.message}"
        assert False, msg


@step('the response timestamp attribute is at most "{ms:d}" ms ago')
def step_impl(context, ms):
    now = datetime.now()
    timestamp = parse(context.res.json()["timestamp"])
    diff = now - timestamp

    actual_ms = diff.total_seconds() * 1000
    print(" TIMING DEBUG ".center(80, "-"))
    print("Timestamp:", timestamp)
    print("Current timestamp:", now)
    print("Diff: ", diff)
    print("Diff in ms:", actual_ms)
    print("-" * 80)

    assert actual_ms >= 0, f"Timestamp is {actual_ms:.2f} ms into the future"
    assert actual_ms <= ms, f"Timestamp is {actual_ms:.2f} ms ago"
