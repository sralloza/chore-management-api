from string import ascii_uppercase

from behave import *

from common.utils import *


@given("there is {chore_types:d} chore type")
@given("there are {chore_types:d} chore types")
def step_impl(context, chore_types):
    for i in range(chore_types):
        raw_data = {"id": ascii_uppercase[i], "description": f"description{i+1}"}
        context.execute_steps(
            f"""
            When I send a request to the Api resource "createChoreType" with body params
            {payload_to_table_format(raw_data)}
            Then the response status code is "200"
            """
        )

    context.res = None


@given("there is {tenants:d} tenant")
@given("there are {tenants:d} tenants")
def step_impl(context, tenants):
    for i in range(1, tenants + 1):
        raw_data = {"tenant_id": i, "username": f"tenant{i}"}
        context.execute_steps(
            f"""
            When I send a request to the Api resource "createTenant" with body params
            {payload_to_table_format(raw_data)}
            Then the response status code is "200"
            """
        )

    context.res = None


@given('the tenant "{tenant_id:d}" skips the week "{week_id}"')
def step_impl(context, tenant_id, week_id):
    context.execute_steps(
        f"""
        Given the field "tenantId" with value "{tenant_id}"
        And the field "weekId" with string value "{week_id}"
        When I send a request to the Api resource "skipWeek"
        Then the response status code is "204"
        """
    )

    context.res = None


@step("a tenant starts a chore transfer to other tenant using the API")
def step_impl(context):
    attrs = ["tenant_id_from", "tenant_id_to", "chore_type", "week_id"]
    context.table.require_columns(attrs)

    nrows = len(list(context.table))
    assert nrows == 1, f"Only one row is allowed, found {nrows}"

    row = context.table.rows[0]

    payload = {}
    for attr in attrs:
        value = row.get(attr)
        if value is not None:
            value = replace_param(value, infer_param_type=attr != "week_id")
            payload[attr] = value

    context.execute_steps(
        f"""
    When I send a request to the Api resource "startTransfer" with body params
    {payload_to_table_format(payload)}
    Then the response status code is "200"
    """
    )
