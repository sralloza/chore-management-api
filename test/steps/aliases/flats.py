from behave import *

from common.alias.users import create_user

# TODO: move this to aliases.users

@given("I create a user")
def step_impl(context):
    create_user(context)


@given("I create a user and I use the user API key")
def step_impl(context):
    context.execute_steps(
        """
        Given I create a user
        And I use the user API key
    """
    )
