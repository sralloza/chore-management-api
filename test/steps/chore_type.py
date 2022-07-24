from string import ascii_uppercase

from behave import *

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


# TODO: remove
@when("I list the chore types using the API")
def step_impl(context):
    context.res = context.get("/chore-types")



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
