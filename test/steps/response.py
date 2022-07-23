from json import loads
from behave import *
from pathlib import Path
from deepdiff import DeepDiff


@step("the Api response contains the expected JSON")
def step_impl(context):
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
