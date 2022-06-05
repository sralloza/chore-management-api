from unittest import mock
from behave import step, given, then
from common.tenant import *
from common.common import assert_arrays_equal


@given("there is {tenants:d} tenant")
@given("there are {tenants:d} tenants")
def step_impl(context, tenants):
    for i in range(1, tenants + 1):
        payload = {"telegram_id": i, "username": f"tenant{i}"}

        context.res = context.post("/tenants", json=payload)
        context.execute_steps('Given the response status code is "200"')
    context.res = None


@step('I create a tenant with name "{name}" and id {tenant_id:d} using the API')
def step_impl(context, name, tenant_id):
    payload = {"telegram_id": tenant_id, "username": name}

    context.res = context.post("/tenants", json=payload)


@step("I list the tenants using the API")
def step_impl(context):
    context.res = context.get("/tenants")


@step("I remove the tenant with id {tenant_id} using the API")
def step_impl(context, tenant_id):
    context.res = context.delete(f"/tenants/{tenant_id}")


@step("the response should contain the following tenants")
def step_impl(context):
    expected_tenants = get_tenants_from_feature_table(context)
    actual_tenants = [Tenant(**x) for x in context.res.json()]

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
