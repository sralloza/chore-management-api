from behave import step, then

from common.tickets import parse_tickets_res_table_str
from common.utils import assert_arrays_equal, parse_table, table_to_str


@step("The response contains the following tickets")
def step_check_response_tickets(context):
    context.execute_steps("Given the response body is a valid json")
    actual = parse_tickets_res_table_str(context.res, lambda x: x["tenant"])
    expected = parse_table(context.table)
    assert_arrays_equal(expected, actual)


@then("the database contains the following tickets")
def step_check_db_tickets(context):
    context.execute_steps(
        f"""
    Given I use the admin API key
    When I send a request to the Api resource "listTickets"
    Then the response contains the following tickets
    {table_to_str(context.table)}
    And I clear the token
    """
    )
