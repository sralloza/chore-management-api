from unittest import mock
from behave import step
from common.tenant import *


@step("there is {tenants:d} tenant")
@step("there are {tenants:d} tenants")
def step_impl(context, tenants):
    for i in range(1, tenants + 1):
        payload = {"telegram_id": i, "username": f"tenant{i}"}

        context.res = context.post("/tenants", json=payload)
        context.execute_steps('Given the response status code is "200"')
    context.res = None


@step('I create a tenant with name "{name}" and id {tenant_id:d}')
def step_impl(context, name, tenant_id):
    payload = {"telegram_id": tenant_id, "username": name}

    context.res = context.post("/tenants", json=payload)


@step(
'a tenant with name "{name}" and id {tenant_id:d} is in the tenants list response'
)
def step_impl(context, name, tenant_id):
    tenants = get_tenants(context)
    expected = Tenant(username=name, telegram_id=tenant_id, api_token=mock.ANY)

    assert expected in tenants, f"{expected} is not in {tenants}"
