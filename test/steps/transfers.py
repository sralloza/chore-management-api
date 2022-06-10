from behave import step
from common.common import assert_arrays_equal, parse_table, replace_param, table_to_str


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


@step('a tenant completes a chore transfer with id "{transfer_id}" using the API')
@step('a tenant completes a chore transfer with id saved as "{attr}" using the API')
def step_impl(context, transfer_id=None, attr=None):
    if transfer_id is None:
        if attr is not None:
            transfer_id = getattr(context, attr)
        else:
            transfer_id = context.transfer_id
    context.res = context.post(f"/transfers/complete/{transfer_id}")


@step("I list the transfers using the API")
def step_impl(context):
    context.res = context.get("/transfers")


@step("the response contains the following transfers")
def step_impl(context):
    context.execute_steps("Given the response body is a valid json")

    actual = context.res.json()
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
