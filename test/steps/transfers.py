from behave import step

from common.common import *


@step("a tenant starts a chore transfer to other tenant using the API")
def step_impl(context):
    attrs = ["tenant_id_from", "tenant_id_to", "chore_type", "week_id"]

    nrows = len(list(context.table))
    assert nrows == 1, f"Only one row is allowed, found {nrows}"

    row = context.table.rows[0]

    payload = {}
    for attr in attrs:
        value = row.get(attr)
        if value is not None:
            value = replace_param(context, value)
            payload[attr] = value
            if attr == "week_id" and value is not None:
                payload[attr] = str(payload[attr])

    context.res = context.post("/transfers/start", json=payload)


@step('I get the transfer with id saved as "{attr}" using the API')
@step('I get the transfer with id "{transfer_id}" using the API')
def step_impl(context, transfer_id=None, attr=None):
    if transfer_id is None:
        if attr is not None:
            transfer_id = getattr(context, attr)
        else:
            transfer_id = context.transfer_id
    context.res = context.get(f"/transfers/{transfer_id}")


@step('a tenant accepts the chore transfer with id "{transfer_id}" using the API')
@step('a tenant accepts the chore transfer with id saved as "{attr}" using the API')
def step_impl(context, transfer_id=None, attr=None):
    if transfer_id is None:
        if attr is not None:
            transfer_id = getattr(context, attr)
        else:
            transfer_id = context.transfer_id
    context.res = context.post(f"/transfers/accept/{transfer_id}")


@step('a tenant rejects the chore transfer with id "{transfer_id}" using the API')
@step('a tenant rejects the chore transfer with id saved as "{attr}" using the API')
def step_impl(context, transfer_id=None, attr=None):
    if transfer_id is None:
        if attr is not None:
            transfer_id = getattr(context, attr)
        else:
            transfer_id = context.transfer_id
    context.res = context.post(f"/transfers/reject/{transfer_id}")


@step("I list the transfers using the API")
def step_impl(context):
    context.res = context.get("/transfers")


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
    When I list the transfers using the API
    Then the response contains the following transfers
    {table_to_str(context.table)}
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
