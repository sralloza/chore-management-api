from string import ascii_uppercase

from behave import step
from common.chore_type import *
from common.common import assert_arrays_equal, replace_param


@step("there is {chore_types:d} chore type")
@step("there are {chore_types:d} chore types")
def step_impl(context, chore_types):
    for i in range(chore_types):
        payload = {
            "id": ascii_uppercase[i],
            "description": f"description{i+1}",
        }
        context.res = context.post("/chore-types", json=payload)
        context.execute_steps('Given the response status code is "200"')

    context.res = None


@step("I create the following chore type using the API")
def step_impl(context):
    assert len(list(context.table)) == 1, "Expected 1 row"

    payload = {
        "id": replace_param(context, context.table[0]["id"]),
        "description": replace_param(context, context.table[0]["description"]),
    }
    context.res = context.post("/chore-types", json=payload)


@step("I list the chore types using the API")
def step_impl(context):
    context.res = context.get("/chore-types")


@step('I get the chore type with id "{chore_id}" using the API')
def step_impl(context, chore_id):
    context.res = context.get(f"/chore-types/{chore_id}")


@step("I delete the chore type with id {chore_id} using the API")
def step_impl(context, chore_id):
    context.res = context.delete(f"/chore-types/{chore_id}")


@step("the response contains the following chore type")
@step("the response contains the following chore types")
def step_impl(context):
    expected = get_chore_types_from_feature_table(context)
    actual = get_chore_types_from_res(context)

    assert_arrays_equal(expected, actual)
