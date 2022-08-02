from behave import *

from common.utils import *


@given("there is {tenants:d} tenant")
@given("there are {tenants:d} tenants")
def step_impl(context, tenants):
    for i in range(1, tenants + 1):
        raw_data = {"tenant_id": i, "username": f"tenant{i}"}
        context.execute_steps(
            f"""
            Given I use the admin token
            When I send a request to the Api resource "createTenant" with body params
            {payload_to_table_format(raw_data)}
            Then the response status code is "200"
            And I clear the token
            """
        )


@given('the tenant "{tenant_id}" skips the week "{week_id}"')
def step_impl(context, tenant_id, week_id):
    context.execute_steps(
        f"""
        Given the field "tenantId" with value "{tenant_id}"
        And I use the token of the tenant with id "{tenant_id}"
        And the field "weekId" with string value "{week_id}"
        When I send a request to the Api resource "skipWeek"
        Then the response status code is "204"
        And I clear the token
        """
    )
