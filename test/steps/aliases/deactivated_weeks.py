from behave import *


@given("I deactivate the chore creation for the week {week_id}")
def step_impl(context, week_id):
    context.execute_steps(
        f"""
        Given the field "week_id" with value "{week_id}"
        And I use the admin API key
        When I send a request to the Api resource "deactivateWeekSystem"
        Then the response status code is "200"
        And I clear the token
        """
    )
    del context.week_id
