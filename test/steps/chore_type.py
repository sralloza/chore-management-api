from string import ascii_uppercase

from behave import *
from toolium.utils.dataset import replace_param

from common.chore_type import *
from common.utils import *


@given("there is {chore_types:d} chore type")
@given("there are {chore_types:d} chore types")
def step_impl(context, chore_types):
    for i in range(chore_types):
        payload = {
            "id": ascii_uppercase[i],
            "description": f"description{i+1}",
        }
        context.res = context.post("/chore-types", json=payload)
        context.execute_steps('Then the response status code is "200"')

    context.res = None


@when("I create a chore type type using the API")
def step_impl(context):
    assert len(list(context.table)) == 1, "Expected 1 row"

    payload = {
        "id": replace_param(context.table[0]["id"]),
        "description": replace_param(context.table[0]["description"]),
    }
    context.res = context.post("/chore-types", json=payload)


# TODO: remove
@when("I list the chore types using the API")
def step_impl(context):
    context.res = context.get("/chore-types")


@when('I delete the chore type with id "{chore_id}" using the API')
def step_impl(context, chore_id):
    context.res = context.delete(f"/chore-types/{chore_id}")


@then("the response contains the following chore type")
@then("the response contains the following chore types")
def step_impl(context):
    expected = get_chore_types_from_feature_table(context)
    actual = get_chore_types_from_res(context)

    assert_arrays_equal(expected, actual)


@then("the database contains the following chore types")
def step_impl(context):
    if not context.table:
        print("Warning: no table data")

    table_as_text = table_to_str(context.table)
    context.execute_steps(
        "When I list the chore types using the API\n"
        + "Then the response contains the following chore types\n"
        + f"{table_as_text}"
    )
