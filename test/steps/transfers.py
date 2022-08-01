from behave import step

from common.utils import *


@step("the response contains the following transfers")
def step_impl(context):
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

    assert_arrays_equal(expected, actual)


@step("the database contains the following transfers")
def step_impl(context):
    context.execute_steps(
        f"""
    Given I use the admin token
    When I send a request to the Api resource "listTransfers"
    Then the response contains the following transfers
    {table_to_str(context.table)}
    And I clear the token
    """
    )


@step("I transfer a chore using the API")
def step_impl(context):
    table_str = table_to_str(context.table)
    context.execute_steps(
        f"""
        When a tenant starts a chore transfer to other tenant using the API
        {table_str}
        Given I save the "id" attribute of the response as "transferId"
        And I use the admin token
        And I send a request to the Api resource "acceptTransfer"
        Then the response status code is "200"
        And I clear the token
        """
    )


@step("the following transfers are created")
def step_impl(context):
    assert_has_table(context)
    context.table.require_columns(
        ["tenant_id_from", "tenant_id_to", "chore_type", "week_id", "accepted"]
    )

    table = parse_table(context.table)

    for line in table:
        accepted = line["accepted"]
        del line["accepted"]

        attr_name = line.get("id_attr_name", "transfer_id")
        table_str = list_of_dicts_to_table_str([line])
        context.execute_steps(
            f"""
        When a tenant starts a chore transfer to other tenant using the API
        {table_str}
        And I save the "id" attribute of the response as "{attr_name}"
        """
        )

        transfer_id = getattr(context, attr_name)

        if accepted is True:
            context.execute_steps(
                f"""
                When a tenant accepts the chore transfer with id "{transfer_id}" using the API
                Then the response status code is "200"
                """
            )
        elif accepted is False:
            context.execute_steps(
                f"""
                When a tenant rejects the chore transfer with id "{transfer_id}" using the API
                Then the response status code is "200"
                """
            )
        elif accepted is not None:
            raise ValueError(
                f"accepted must be True, False or None, found {accepted!r}"
            )
