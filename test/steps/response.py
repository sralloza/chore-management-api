from json import loads
from pathlib import Path

from behave import *
from deepdiff import DeepDiff


@step("the Api response contains the expected data")
def step_impl(context):
    if context.text:
        text = context.text
        body_params = loads(text) if isinstance(text, str) else text
        res_json = context.res.json()
        msg = f"Expected response: {body_params}, Adapter response: {res_json}"
        assert body_params == res_json, msg
        return

    json_file = (
        Path(__file__).parent.parent
        / f"resources/responses/{context.api}/{context.resource}.json"
    )

    if not json_file.is_file():
        raise FileNotFoundError(f'Not found file "{json_file}"')

    context.logger.debug(f'JSON response file: "{json_file}"')
    expected_json = loads(json_file.read_text("utf8"))
    actual_json = context.res.json()

    diff = DeepDiff(expected_json, actual_json)
    assert not diff, f"JSON response differs: {diff}"
