import json
import re
import uuid

import jq
from behave import given, step, then
from hamcrest import assert_that, equal_to, is_in
from toolium.utils.dataset import replace_param

from common.api import send_request
from common.request import table_to_dict
from common.utils import toolium_replace


@then('the response status code is "{code:d}"')
def step_check_response_status_code(context, code):
    actual = context.res.status_code
    assert_that(actual, equal_to(code), f"Expected status code {code}, got {actual}")


@step("the response body is a valid json")
def step_response_body_valid_json(context):
    try:
        json.loads(context.res.text)
    except ValueError as exc:
        assert False, f"Response body is not a valid json ({exc})"


@step('the error message contains "{message}"')
def step_check_error_message_contains_message(context, message):
    assert "detail" in context.res.json(), "No error message in response"
    actual = context.res.json()["detail"]
    error_msg = f'The error message should contain "{message}", but it is "{actual}"'
    assert re.search(message, actual), error_msg


@step('the error message is "{message}"')
def step_check_error_message(context, message=None):
    message = message or context.text
    message = replace_param(message, infer_param_type=False)
    assert "detail" in context.res.json(), "No error message in response"
    actual = context.res.json()["detail"]

    msg = 'The error message should be "{}", but it is "{}"'
    assert actual == message, msg.format(message, actual)


@step("the parameters to filter the request")
def step_set_request_query_params(context):
    context.params = table_to_dict(context.table)


@step('I send a request to the Api resource "{resource}"')
def step_send_request_api_resource(context, resource):
    send_request(context, resource)


@step('I send a request to the Api resource "{resource}" with body params')
def step_send_request_api_resource_body(context, resource):
    payload = table_to_dict(context.table)
    send_request(context, resource, payload=payload)


@step("I send a request to the Api with body params")
def step_send_request_body(context):
    payload = table_to_dict(context.table)
    send_request(context, payload=payload)


@step("I send a request to the Api with body")
def step_send_request_raw_body(context):
    send_request(context, payload=context.text, raw_payload=True)


@step("I send a request to the Api")
def step_send_request(context):
    send_request(context)


@step('the field "{field}" with string value "{value}"')
def step_set_context_string_field(context, field, value):
    set_field_to_context(context, field, value, to_str=True)


@step('the field "{field}" with value "{value}"')
def set_field_to_context(context, field, value, to_str=False):
    value = toolium_replace(value, infer_param_type=not to_str)
    setattr(context, field, value)


@step('the field "{field}" saved as "{attr}"')
def step_rename_context_field(context, field, attr):
    value = getattr(context, attr)
    set_field_to_context(context, field, value)


@step("the fields")
def step_set_context_fields(context):
    context.table.require_columns(["field", "value"])
    for row in context.table:
        field = row["field"]
        value = row["value"]
        to_str = row.get("as_string", "false").lower() == "true"
        set_field_to_context(context, field, value, to_str=to_str)


@step("the request headers")
def set_set_request_headers(context):
    context.table.require_columns(["header_name", "header_value"])
    context.headers = {}
    for row in context.table:
        header = row["header_name"]
        value = row["header_value"]
        context.headers[header] = value


@step("the {correlator} as X-Correlator header")
def step_set_correlator_header(context, correlator):
    if correlator == "[RANDOMSTR]":
        generated_correlator = uuid.uuid4().hex.upper()[0:6]
    elif correlator == "[UUIDv1]":
        generated_correlator = str(uuid.uuid1())
    elif correlator == "[UUIDv4]":
        generated_correlator = str(uuid.uuid4())
    else:
        generated_correlator = correlator

    context.execute_steps(
        f"""
        Given the request headers
          | header_name  | header_value           |
          | X-Correlator | {generated_correlator} |
        """
    )

    # Save it
    context.correlator = generated_correlator


@step('I clear the "{attr}" attribute of the context')
def step_clear_context_attribute(context, attr):
    if hasattr(context, attr):
        delattr(context, attr)


@step('the response attribute "{attr}" as string is "{value}"')
def step_check_response_attribute_string(context, attr, value):
    step_check_response_attribute(context, attr, value, to_str=True)


@step('the response attribute "{attr}" is "{value}"')
def step_check_response_attribute(context, attr, value, to_str=False):
    res_json = context.res.json()

    expected_value = replace_param(value, infer_param_type=not to_str)

    attr = "." + attr if not attr.startswith(".") else attr
    real_value = jq.compile(attr).input(res_json).first()

    assert_that(
        real_value,
        equal_to(expected_value),
        f"Expected attribute {attr} to be {value}",
    )


@step("the X-Correlator sent is the same as the X-Correlator in the response")
def step_same_header_correlator(context):
    assert_that(
        context.res.headers["X-Correlator"],
        equal_to(context.correlator),
        "X-Correlator sent is not the same as the X-Correlator in the response",
    )


@step('the X-Correlator is present in the response')
def step_header_not_present(context):
    assert_that(
        "X-Correlator",
        is_in(context.res.headers),
        "The X-Correlator header is not present in the response",
    )


@given("I don't include the X-Correlator header in the request")
def step_do_not_send_xcorelator_header(context):
    context.headers = {}
