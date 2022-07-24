from json import JSONDecodeError, loads
from pathlib import Path

from behave import *
from deepdiff import DeepDiff

from common.response import get_step_body_json

RESPONSES_PATH = Path(__file__).parent.parent / "resources/responses"


@step("the Api response contains the expected data")
def step_impl(context):
    json_file = None
    if context.text:
        try:
            body_params = get_step_body_json(context)
            res_json = context.res.json()

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

    diff = DeepDiff(expected_json, actual_json)
    assert not diff, f"JSON response differs: {diff}"
