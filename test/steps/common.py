from behave import *


@given(
    'there are {a:d} tenants, {b:d} chore types and weekly chores for the week "{week_id}"'
)
def step_impl(context, a, b, week_id):
    context.execute_steps(
        f"""
        Given there are {a} tenants
        And there are {b} chore types
        And I create the weekly chores for the week "{week_id}" using the API
    """
    )
