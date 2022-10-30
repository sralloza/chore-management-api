from uuid import uuid4

from behave import *
from hamcrest import assert_that, is_in

VALID_API_KEYS = ("admin", "flat", "user")


@step("I use the {api_key} API key")
def step_impl(context, api_key):
    assert_that(api_key, is_in(VALID_API_KEYS))
    context.token = getattr(context, f"{api_key}_api_key")


@step("I use a random API key")
def step_impl(context):
    context.token = str(uuid4())


@step("I clear the token")
def step_impl(context):
    context.token = None
