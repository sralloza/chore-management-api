import json
import re
from datetime import datetime

import jq
from behave import *
from dateutil.parser import parse
from hamcrest import *
from toolium.utils.dataset import replace_param

from common.api import send_request
from common.request import table_to_dict


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
    message = replace_param(message, infer_param_type=False)
    assert "message" in context.res.json(), "No error message in response"
    actual = context.res.json()["message"]

    msg = 'The error message should be "{}", but it is "{}"'
    assert actual == message, msg.format(message, actual)


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


@step("the parameters to filter the request")
def step_impl(context):
    context.params = table_to_dict(context.table)


@step('I send a request to the Api resource "{resource}"')
def step_impl(context, resource):
    send_request(context, resource)


@step('I send a request to the Api resource "{resource}" with body params')
def step_impl(context, resource):
    payload = table_to_dict(context.table)
    send_request(context, resource, payload=payload)


@step("I send a request to the Api with body params")
def step_impl(context):
    payload = table_to_dict(context.table)
    send_request(context, payload=payload)


@step("I send a request to the Api with body")
def step_impl(context):
    send_request(context, payload=context.text)


@step("I send a request to the Api")
def step_impl(context):
    send_request(context)


@step('the field "{field}" with string value "{value}"')
def step_impl(context, field, value):
    set_field_to_context(context, field, value, to_str=True)


@step('the field "{field}" with value "{value}"')
def set_field_to_context(context, field, value, to_str=False):
    value = replace_param(value, infer_param_type=not to_str)
    setattr(context, field, value)


@step('the field "{field}" saved as "{attr}"')
def step_impl(context, field, attr):
    value = getattr(context, attr)
    set_field_to_context(context, field, value)


@step("the fields")
def step_impl(context):
    context.table.require_columns(["field", "value"])
    for row in context.table:
        field = row["field"]
        value = row["value"]
        to_str = row.get("as_string", "fals").lower() == "true"
        set_field_to_context(context, field, value, to_str=to_str)


@step("the request headers")
def step_impl(context):
    context.table.require_columns(["header", "value"])
    context.headers = {}
    for row in context.table:
        header = row["header"]
        value = row["value"]
        context.headers[header] = value


@step('I clear the "{attr}" attribute of the context')
def step_impl(context, attr):
    if hasattr(context, attr):
        delattr(context, attr)


@step('the response attribute "{attr}" as string is "{value}"')
def step_impl(context, attr, value):
    assert_response_attr(context, attr, value, to_str=True)


@step('the response attribute "{attr}" is "{value}"')
def assert_response_attr(context, attr, value, to_str=False):
    res_json = context.res.json()

    expected_value = replace_param(value, infer_param_type=not to_str)

    attr = "." + attr if not attr.startswith(".") else attr
    real_value = jq.compile(attr).input(res_json).first()

    assert_that(
        real_value,
        equal_to(expected_value),
        f"Expected attribute {attr} to be {value}",
    )
