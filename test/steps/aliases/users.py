from behave import *

from common.utils import *


@given("there is {users:d} user")
@given("there are {users:d} users")
def step_impl(context, users):
    for i in range(1, users + 1):
        raw_data = {"id": f"user-{i}", "username": f"user-{i}"}
        context.execute_steps(
            f"""
            Given I use the admin API key
            When I send a request to the Api resource "createUser" with body params
            {payload_to_table_format(raw_data)}
            Then the response status code is "200"
            And I clear the token
            """
        )


@given('the user "{user_id}" skips the week "{week_id}"')
def step_impl(context, user_id, week_id):
    context.execute_steps(
        f"""
        Given the field "user_id" with value "{user_id}"
        And I use the token of the user with id "{user_id}"
        And the field "week_id" with string value "{week_id}"
        When I send a request to the Api resource "skipWeek"
        Then the response status code is "204"
        And I clear the token
        """
    )
