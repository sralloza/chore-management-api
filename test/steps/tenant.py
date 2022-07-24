from behave import *

from common.tenant import *
from common.utils import *


@given("there is {tenants:d} tenant")
@given("there are {tenants:d} tenants")
def step_impl(context, tenants):
    for i in range(1, tenants + 1):
        payload = {"tenant_id": i, "username": f"tenant{i}"}

        context.res = context.post("/tenants", json=payload)
        context.execute_steps('Then the response status code is "200"')
    context.res = None


@when("I save the tenant's token")
def step_impl(context):
    context.execute_steps(
        """
    Given the response body is a valid json
    And the response status code is "200"
    """
    )
    context.api_token = context.res.json()["api_token"]


@when('I recreate the token of the tenant with id "{tenant_id:d}" using the API')
def step_impl(context, tenant_id):
    context.res = context.post(f"/tenants/{tenant_id}/recreate-token")


@then("the tenant's token is different from the saved token")
def step_impl(context):
    context.execute_steps(
        """
    Given the response body is a valid json
    And the response status code is "200"
    """
    )
    new_token = context.res.json()["api_token"]
    assert (
        new_token != context.api_token
    ), f"{new_token} is the same as {context.api_token}"
