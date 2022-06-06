from unittest import mock

from behave import given, step, then
from toolium.utils.dataset import replace_param

from common.common import assert_arrays_equal
from common.tenant import *


@step("I get the tenant with id {tenant_id} using the API")
def step_impl(context, tenant_id):
    context.res = context.get(f"/tenants/{tenant_id}")


@given("there is {tenants:d} tenant")
@given("there are {tenants:d} tenants")
def step_impl(context, tenants):
    for i in range(1, tenants + 1):
        payload = {"telegram_id": i, "username": f"tenant{i}"}

        context.res = context.post("/tenants", json=payload)
        context.execute_steps('Given the response status code is "200"')
    context.res = None


@step('I create a tenant with name "{name}" and id {tenant_id:d} using the API')
@step('I create a tenant with name "{name}" and custom id {tenant_id} using the API')
def step_impl(context, name, tenant_id):
    payload = {
        "telegram_id": replace_param(tenant_id),
        "username": replace_param(name),
    }

    context.res = context.post("/tenants", json=payload)


@step('I create a tenant with body "{body}" using the API')
def step_impl(context, body):
    context.res = context.post("/tenants", json=body)


@step("I list the tenants using the API")
def step_impl(context):
    context.res = context.get("/tenants")


@step("I delete the tenant with id {tenant_id} using the API")
def step_impl(context, tenant_id):
    context.res = context.delete(f"/tenants/{tenant_id}")


@step("I save the tenant's token")
def step_impl(context):
    context.execute_steps(
        """
    Given the response body is a valid json
    And the response status code is "200"
    """
    )
    context.api_token = context.res.json()["api_token"]


@step("I recreate the token of the tenant with id {tenant_id} using the API")
def step_impl(context, tenant_id):
    context.res = context.post(f"/tenants/{tenant_id}/recreate-token")


@step("the response should contain the following tenants")
def step_impl(context):
    expected_tenants = get_tenants_from_feature_table(context)
    actual_tenants = get_tenants_from_response(context)

    assert_arrays_equal(expected_tenants, actual_tenants)


@then(
    'a tenant with name "{name}" and id {tenant_id:d} is in the tenants list response'
)
def step_impl(context, name, tenant_id):
    tenants = get_tenants(context)
    expected = Tenant(username=name, telegram_id=tenant_id, api_token=mock.ANY)

    assert expected in tenants, f"{expected} is not in {tenants}"


@then("a tenant with id {tenant_id} is not in the tenants list response")
def step_impl(context, tenant_id):
    tenants = get_tenants(context)
    expected = Tenant(username=mock.ANY, telegram_id=tenant_id, api_token=mock.ANY)

    assert expected not in tenants, f"{expected} is not in {tenants}"


@step("the tenant's token is different from the saved token")
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


@step("the tenant's token is equal to the saved token")
def step_impl(context):
    context.execute_steps(
        """
    Given the response body is a valid json
    And the response status code is "200"
    """
    )
    new_token = context.res.json()["api_token"]
    assert (
        new_token == context.api_token
    ), f"{new_token} is different as {context.api_token}"
