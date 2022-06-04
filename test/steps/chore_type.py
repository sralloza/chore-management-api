from string import ascii_uppercase

from behave import step


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
