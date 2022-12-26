from json import JSONDecodeError, loads
from pathlib import Path

import jq
from behave import step, then
from deepdiff import DeepDiff
from hamcrest import assert_that, equal_to, has_key, is_not

from common.response import get_step_body_json
from common.utils import map_param_nested_obj, remove_attributes, toolium_replace

RESPONSES_PATH = Path(__file__).parent.parent / "resources/responses"


@step("the Api response is empty")
def step_response_empty(context):
    msg = f"Response is not empty: {context.res.text}"
    assert context.res.text == "", msg


@step("the Api response contains the expected data")
def step_response_expected_data(context):
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
            res_json = remove_attributes(res_json, skip_params)

            msg = f"Expected response: {body_params}, API response: {res_json}"
            assert body_params == res_json, msg
            return
        except JSONDecodeError:
            json_file = RESPONSES_PATH / context.api / f"{context.text.strip()}.json"

    if not json_file:
        json_file = RESPONSES_PATH / f"{context.api}/{context.operation_id}.json"

    if not json_file.is_file():
        raise FileNotFoundError(f'Not found file "{json_file}"')

    expected_json = map_param_nested_obj(loads(json_file.read_text("utf8")))

    context.logger.debug(f'JSON response file: "{json_file}"')

    actual_json = context.res.json()
    actual_json = remove_attributes(actual_json, skip_params)

    diff = DeepDiff(expected_json, actual_json)
    assert not diff, f"JSON response differs: {diff}"


@then('the response field "{res_attr}" is different than "{value}"')
def step_check_response_field_different(context, res_attr, value):
    res_attr = "." + res_attr if not res_attr.startswith(".") else res_attr
    res_json = context.res.json()
    actual = jq.compile(res_attr).input(res_json).first()
    expected = toolium_replace(value)
    assert_that(expected, is_not(equal_to(actual)))


@then('the response field "{res_attr}" is equal to "{value}"')
def step_check_response_field_equal(context, res_attr, value):
    res_attr = "." + res_attr if not res_attr.startswith(".") else res_attr
    res_json = context.res.json()
    actual = jq.compile(res_attr).input(res_json).first()
    expected = toolium_replace(value)
    assert_that(expected, equal_to(actual))


@step('I save the "{attr}" attribute of the response as "{dest}"')
def step_save_response_attr(context, attr, dest):
    res_json = context.res.json()
    assert_that(res_json, has_key(attr))
    setattr(context, dest, res_json[attr])
