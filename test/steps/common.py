from behave import given


@given(
    "there are {a:d} users, {b:d} chore types and "
    'weekly chores for the week "{week_id}"'
)
@given(
    'there is {a:d} user, {b:d} chore type and weekly chores for the week "{week_id}"'
)
def step_create_user_chore_type_weekly_chores(context, a, b, week_id):
    context.execute_steps(
        f"""
        Given there are {a} users
        And there are {b} chore types
        And I create the weekly chores for the week "{week_id}" using the API
    """
    )
