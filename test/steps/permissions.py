from behave import *


@step("I use a tenant's token")
def step_impl(context):
    context.execute_steps(
        """
        When I send a request to the Api resource "listTenants"
        Then the response status code is "200"
        """
    )

    if not context.res.json():
        context.execute_steps(
            """
            Given There is 1 tenant
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

    context.execute_steps(
        f"""
        Given I use the admin token
        And the field "tenantId" with value "{id}"
        When I send a request to the Api resource "getTenant"
        Then the response status code is "200"
        """
    )

    context.token = context.res.json()["api_token"]
    context.res = None


@step("I use the admin token")
def step_impl(context):
    context.token = context.admin_token


@step("I clear the token")
def step_impl(context):
    context.token = None
