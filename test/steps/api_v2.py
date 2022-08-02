import jq
from behave import *
from hamcrest import *
from toolium.utils.dataset import replace_param

from common.api_v2 import send_request
from common.request import table_to_dict


@step("The parameters to filter the request")
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


@step('the response attribute "{attr}" as string is "{value}"')
def step_impl(context, attr, value):
    assert_response_attr(context, attr, value, to_str=True)


@step('The response attribute "{attr}" is "{value}"')
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
