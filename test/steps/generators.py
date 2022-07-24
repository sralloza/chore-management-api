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
