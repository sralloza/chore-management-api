from behave import step

from common.utils import assert_arrays_equal, parse_table, table_to_str


@step("the response contains the following transfers")
def step_check_response_transfers(context):
    context.execute_steps("Given the response body is a valid json")

    actual = context.res.json()
    if not isinstance(actual, list):
        actual = [actual]
    for line in actual:
        del line["id"]
        del line["timestamp"]

    expected = parse_table(context.table)
    for line in expected:
        line["week_id"] = str(line["week_id"])

    # TODO: do not use assert_arrays_equal
    assert_arrays_equal(expected, actual)


@step("the database contains the following transfers")
def step_check_db_transfers(context):
    context.execute_steps(
        f"""
    Given I use the admin API key
    When I send a request to the Api resource "listTransfers"
    Then the response contains the following transfers
    {table_to_str(context.table)}
    And I clear the token
    """
    )
