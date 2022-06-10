from behave import *

from common.common import assert_arrays_equal, parse_table, table_to_str
from common.tickets import parse_tickets_res_table_str


@step("I list the tickets using the API")
def step_impl(context):
    context.res = context.get("/tickets")


@step("The response contains the following tickets")
def step_impl(context):
    context.execute_steps("Given the response body is a valid json")
    actual = parse_tickets_res_table_str(context.res, lambda x: x["tenant"])
    expected = parse_table(context.table)
    assert_arrays_equal(expected, actual)


@then("the database contains the following tickets")
def step_impl(context):
    context.execute_steps(
        f"""
    Given I list the tickets using the API
    And the response contains the following tickets
    {table_to_str(context.table)}
    """
    )
