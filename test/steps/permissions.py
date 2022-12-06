from uuid import uuid4

from behave import *
from hamcrest import assert_that, is_in

VALID_API_KEYS = ("admin", "flat", "user")


@step("I use the {api_key} API key")
def step_impl(context, api_key):
    assert_that(api_key, is_in(VALID_API_KEYS))
    context.token = getattr(context, f"{api_key}_api_key")


@step('I use the token of the user with id "{user_id}"')
def step_impl(context, user_id):
    context.execute_steps(
        """
        Given I use the admin API key
        When I send a request to the API resource "listUsers"
        Then the response status code is "200"
        """
    )
    users = context.res.json()
    try:
        context.token = next(user["api_key"] for user in users if user["id"] == user_id)
    except StopIteration:
        raise ValueError(f"User with id {user_id!r} not found ({users})")


@step("I use a random API key")
def step_impl(context):
    context.token = str(uuid4())


@step("I clear the token")
def step_impl(context):
    context.token = None
