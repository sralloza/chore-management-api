from behave import *
from toolium.utils.dataset import replace_param

from common.utils import *


@step("I transfer a chore using the API")
def step_impl(context):
    table_str = table_to_str(context.table)
    context.execute_steps(
        f"""
        Given I use the admin token
        When a tenant starts a chore transfer to other tenant using the API
        {table_str}
        Given I use the admin token
        Given I save the "id" attribute of the response as "transferId"
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
        # TODO: do not use step "a tenant starts a chore transfer to other tenant using the API"
        context.execute_steps(
            f"""
        When a tenant starts a chore transfer to other tenant using the API
        {table_str}
        And I save the "id" attribute of the response as "{attr_name}"
        """
        )

        transfer_id = getattr(context, attr_name)

        template = f"""
        Given the field "transferId" with value "{transfer_id}"
        And I use the token of the tenant with id "{line['tenant_id_to']}"
        When I send a request to the Api resource "{{}}"
        Then the response status code is "200"
        """

        if accepted is True:
            context.execute_steps(template.format("acceptTransfer"))
        elif accepted is False:
            context.execute_steps(template.format("rejectTransfer"))
        elif accepted is not None:
            raise ValueError(
                f"accepted must be True, False or None, found {accepted!r}"
            )


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
    Given I use the token of the tenant with id "{payload['tenant_id_from']}"
    When I send a request to the Api resource "startTransfer" with body params
    {payload_to_table_format(payload)}
    Then the response status code is "200"
    """
    )
