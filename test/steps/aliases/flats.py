from behave import *

from common.alias.flats import create_flat


@given("I create a flat")
def step_impl(context):
    create_flat(context)


@given("I create a flat with a user and I use the user API key")
def step_impl(context):
    context.execute_steps(
        """
        Given I create a flat with a user
        And I use the user API key
    """
    )


@given("I create a flat with a user and I use the flat API key")
def step_impl(context):
    context.execute_steps(
        """
        Given I create a flat with a user
        And I use the flat API key
    """
    )


@given("I create a flat with a user")
def step_impl(context):
    create_flat(context, user=True)


@given("I create a flat and I use the flat API key")
def step_impl(context):
    context.execute_steps(
        """
        Given I create a flat
        And I use the flat API key
    """
    )
