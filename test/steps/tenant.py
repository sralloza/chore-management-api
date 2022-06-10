from unittest import mock

from behave import given, step, then

from common import *


@step("I get the tenant with id {tenant_id} using the API")
def step_impl(context, tenant_id):
    context.res = context.get(f"/tenants/{tenant_id}")


@given("there is {tenants:d} tenant")
@given("there are {tenants:d} tenants")
def step_impl(context, tenants):
    for i in range(1, tenants + 1):
        payload = {"tenant_id": i, "username": f"tenant{i}"}

        context.res = context.post("/tenants", json=payload)
        context.execute_steps('Then the response status code is "200"')
    context.res = None


@step('I create a tenant with name "{username}" using the API')
@step('I create a tenant with id "{tenant_id}" using the API')
@step("I create a tenant using the API")
def step_impl(context, username=None, tenant_id=None):
    tenant_id = tenant_id or context.table[0].get("tenant_id")
    username = username or context.table[0].get("username")

    if context.active_outline:
        tenant_id = context.active_outline.get("tenant_id") or tenant_id
        username = context.active_outline.get("username") or username

    payload = {}
    if tenant_id is not None:
        payload["tenant_id"] = replace_param(context, tenant_id, infer_param_type=False)
    if username is not None:
        payload["username"] = replace_param(context, username, infer_param_type=False)

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


@then("the following tenant exists")
def step_impl(context):
    tenants = get_tenants(context)
    context.table.require_columns(["username", "tenant_id"])

    username = replace_param(context, context.table[0].get("username"))
    tenant_id = replace_param(context, context.table[0].get("tenant_id"))
    expected = Tenant(username=username, tenant_id=tenant_id, api_token=mock.ANY)

    assert expected in tenants, f"{expected} is not in {tenants}"


@then("a tenant with id {tenant_id} is not in the tenants list response")
def step_impl(context, tenant_id):
    tenants = get_tenants(context)
    expected = Tenant(username=mock.ANY, tenant_id=tenant_id, api_token=mock.ANY)

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
