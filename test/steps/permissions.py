from uuid import uuid4
from behave import *
from hamcrest import assert_that, is_in

VALID_API_KEYS = ("admin", "flat", "user")


@step("I use a tenant's token")
def step_impl(context):
    context.execute_steps(
        """
        Given I use the admin API key
        When I send a request to the Api resource "listTenants"
        Then the response status code is "200"
        """
    )

    if not context.res.json():
        context.execute_steps(
            """
            Given There is 1 tenant
            And I use the admin API key
            When I send a request to the Api resource "listTenants"
            Then the response status code is "200"
            """
        )

    context.token = context.res.json()[0]["api_token"]
    context.res = None


@step('I use the token of the tenant with id "{id}"')
def step_impl(context, id):
    if id == "admin":
        context.token = context.admin_token
        return

    if id == "me":
        raise ValueError("Can't get the token from tenant_id = 'me'")

    context.execute_steps(
        f"""
        Given I use the admin API key
        And the field "tenantId" with value "{id}"
        When I send a request to the Api resource "listTenants"
        Then the response status code is "200"
        """
    )

    tokens = [t for t in context.res.json() if t["tenant_id"] == int(id)]
    context.token = tokens[0]["api_token"]
    context.res = None


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
