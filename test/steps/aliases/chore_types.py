from string import ascii_uppercase

from behave import *
from toolium.utils.dataset import map_param

from common.utils import *


@given("there is {chore_types:d} chore type")
@given("there are {chore_types:d} chore types")
def step_impl(context, chore_types):
    for i in range(chore_types):
        raw_data = {"id": ascii_uppercase[i], "description": f"description{i+1}"}
        context.execute_steps(
            f"""
            Given I use the admin token
            When I send a request to the Api resource "createChoreType" with body params
            {payload_to_table_format(raw_data)}
            Then the response status code is "200"
            And I clear the token
            """
        )


@then('the response contains the simple chores "{ids}"')
def step_impl(context, ids):
    ids = replace_param(ids)
    if not ids:
        ids = []
    elif isinstance(ids, str):
        ids = list(map(int, ids.replace(" ", "").split(",")))
    elif isinstance(ids, int):
        ids = [ids]

    original = map_param("[CONF:examples.simple_chore_types]")
    res_json = context.res.json()
    expected = [original[x - 1] for x in ids]

    assert_arrays_equal(expected, res_json)
