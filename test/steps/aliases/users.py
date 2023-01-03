from behave import given

from common.alias.users import create_user


@given("I create a user")
def step_create_user(context):
    create_user(context)


@given("I create a user and I use the user API key")
def step_create_user_and_set_api_key(context):
    context.execute_steps(
        """
        Given I create a user
        And I use the user API key
    """
    )


@given("there is {users:d} user")
@given("there are {users:d} users")
def step_create_users(context, users):
    for i in range(1, users + 1):
        create_user(context, user_id=f"user-{i}", username=f"username-{i}")


@given(
    'the user with id "{user_id}" deactivates its'
    ' chores assigments for the week "{week_id}"'
)
def step_deactivate_chore_assignments(context, user_id, week_id):
    context.execute_steps(
        f"""
        Given the field "user_id" with value "me"
        And I use the token of the user with id "{user_id}"
        And the field "week_id" with string value "{week_id}"
        When I send a request to the Api resource "deactivateWeekUser"
        Then the response status code is "200"
        And I clear the token
        """
    )
