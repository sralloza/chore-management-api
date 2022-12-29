from behave import given

from common.db import execute_query

DEACTIVATE_MSG = (
    'I deactivate the chore creation for the week "{week_id}" and user "{user_id}"'
)


@given(f"{DEACTIVATE_MSG} editing the database")
def step_insert_deactivated_weeks_db(context, week_id, user_id):  # noqa: ARG001
    row_id = f"{week_id}#{user_id}"
    execute_query(
        "INSERT INTO deactivated_weeks (id, week_id, user_id) VALUES (%s, %s, %s)",
        (row_id, week_id, user_id),
        commit=True,
    )


@given(DEACTIVATE_MSG)
def step_deactivate_week_user_api(context, week_id, user_id):
    context.execute_steps(
        f"""
        Given the field "week_id" with string value "{week_id}"
        And the field "user_id" with value "{user_id}"
        And I use the admin API key
        When I send a request to the Api resource "deactivateWeekUser"
        Then the response status code is "200"
        And I clear the token
        """
    )
    del context.week_id


@given('I deactivate the chore creation for the week "{week_id}"')
def step_deactivate_week_system_api(context, week_id):
    context.execute_steps(
        f"""
        Given the field "week_id" with string value "{week_id}"
        And I use the admin API key
        When I send a request to the Api resource "deactivateWeekSystem"
        Then the response status code is "200"
        And I clear the token
        """
    )
    del context.week_id
