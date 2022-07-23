import jq
from behave import *
from hamcrest import *
from toolium.utils.dataset import replace_param

from common.api_v2 import send_request
from common.request import table_to_dict


@step("The parameters to filter the request")
def step_impl(context):
    context.params = table_to_dict(context.table)


@step('I send a request to the Api resource "{resource}" through 4P"')
def step_impl(context, resource):
    send_request(context, resource)


@step("I send a request to the Api with body params")
def step_impl(context):
    payload = table_to_dict(context.table)
    send_request(context, payload=payload)


@step("I send a request to the Api")
def step_impl(context):
    send_request(context)


@step('The field "{field}" with value "{value}"')
def step_impl(context, field, value):
    """
    Save field and value in context
    :param context: behave context
    :param field: context attribute name
    :param value: context attribute value
    """
    setattr(context, field, value)


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
