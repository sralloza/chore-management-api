from string import ascii_lowercase

from behave import given, then
from toolium.utils.dataset import map_param

from common.utils import assert_arrays_equal, payload_to_table_format, replace_param


@given("there is {chore_types:d} chore type")
@given("there are {chore_types:d} chore types")
def step_create_chore_types(context, chore_types):
    for i in range(chore_types):
        raw_data = {
            "id": f"ct-{ascii_lowercase[i]}",
            "name": f"ct-{ascii_lowercase[i]}",
            "description": f"description{i+1}",
        }
        context.execute_steps(
            f"""
            Given I use the admin API key
            When I send a request to the Api resource "createChoreType" with body params
            {payload_to_table_format(raw_data)}
            Then the response status code is "200"
            And I clear the token
            """
        )


@then('the response contains the chores "{ids}"')
def step_response_contains_chores(context, ids):
    ids = replace_param(ids)
    if not ids:
        ids = []
    elif isinstance(ids, str):
        ids = list(map(int, ids.replace(" ", "").split(",")))
    elif isinstance(ids, int):
        ids = [ids]

    original = map_param("[CONF:examples.simple_chore_types]")
    res_json = context.res.json()

    for field_name in ("completed_at", "created_at"):
        for item in res_json:
            del item[field_name]

    expected = [original[x - 1] for x in ids]

    assert_arrays_equal(expected, res_json)
