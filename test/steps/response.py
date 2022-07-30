from json import JSONDecodeError, loads
from pathlib import Path

import jq
from behave import *
from deepdiff import DeepDiff
from hamcrest import *

from common.response import get_step_body_json, remove_attributes

RESPONSES_PATH = Path(__file__).parent.parent / "resources/responses"


@step("The Api response is empty")
def step_impl(context):
    msg = f"Response is not empty: {context.res.text}"
    assert context.res.text == "", msg


@step("the Api response contains the expected data")
def step_impl(context):
    json_file = None
    if context.table:
        context.table.require_columns(["skip_param"])
        skip_params = [x["skip_param"] for x in context.table]
    else:
        skip_params = []

    if context.text:
        try:
            body_params = get_step_body_json(context)
            res_json = context.res.json()
            remove_attributes(res_json, skip_params)

            msg = f"Expected response: {body_params}, Adapter response: {res_json}"
            assert body_params == res_json, msg
            return
        except JSONDecodeError:
            json_file = RESPONSES_PATH / context.text.strip()

    if not json_file:
        json_file = RESPONSES_PATH / f"{context.api}/{context.resource}.json"

    if not json_file.is_file():
        raise FileNotFoundError(f'Not found file "{json_file}"')

    context.logger.debug(f'JSON response file: "{json_file}"')
    expected_json = loads(json_file.read_text("utf8"))
    actual_json = context.res.json()
    remove_attributes(actual_json, skip_params)

    diff = DeepDiff(expected_json, actual_json)
    assert not diff, f"JSON response differs: {diff}"


@step('"I save the response field "{field}" as "{attr}"')
def step_impl(context, field, attr):
    field = "." + field if not field.startswith(".") else field
    context.logger.debug(f'Saving response field "{field}" as "{attr}"')
    res_json = context.res.json()
    value = jq.compile(attr).input(res_json).first()
    setattr(context, attr, value)


@then('the response field "{res_attr}" is different than "{saved_attr}"')
def step_impl(context, res_attr, saved_attr):
    res_attr = "." + res_attr if not res_attr.startswith(".") else res_attr
    res_json = context.res.json()
    actual = jq.compile(res_attr).input(res_json).first()
    expected = getattr(context, saved_attr)
    assert_that(expected, is_not(equal_to(actual)))


@then('the response field "{res_attr}" is equal to "{saved_attr}"')
def step_impl(context, res_attr, saved_attr):
    res_attr = "." + res_attr if not res_attr.startswith(".") else res_attr
    res_json = context.res.json()
    actual = jq.compile(res_attr).input(res_json).first()
    expected = getattr(context, saved_attr)
    assert_that(expected, equal_to(actual))
