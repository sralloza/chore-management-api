from behave import given


@given(
    'the user "{user_id}" has completed the chore '
    '"{chore_type_id}" for the week "{week_id}"'
)
def step_impl(context, user_id, chore_type_id, week_id):
    context.execute_steps(
        f"""
        Given the field "user_id" with value "{user_id}"
        And the field "chore_type_id" with value "{chore_type_id}"
        And the field "week_id" with string value "{week_id}"
        And I use the admin API key
        When I send a request to the Api resource "completeChore"
        Then the response status code is "204"
    """
    )
    del context.chore_type_id
    del context.week_id
    del context.user_id
