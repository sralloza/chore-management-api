from behave import given

from common.utils import assert_has_table, parse_table


@given("the following transfers are created")
def step_create_transfers(context):
    assert_has_table(context)
    context.table.require_columns(
        ["user_id_from", "user_id_to", "chore_type_id", "week_id", "accepted"]
    )

    table = parse_table(context.table)

    for line in table:
        accepted = line["accepted"]
        del line["accepted"]

        attr_name = line.get("id_attr_name", "transfer_id")
        context.execute_steps(
            f"""
        Given I use the token of the user with id "{line['user_id_from']}"
        When I send a request to the Api resource "startTransfer" with body params
            | param_name    | param_value             |
            | user_id_from  | {line['user_id_from']}  |
            | user_id_to    | {line['user_id_to']}    |
            | chore_type_id | {line['chore_type_id']} |
            | week_id       | {line['week_id']}       |
        Then The response status code is "200"
        And I save the "id" attribute of the response as "{attr_name}"
        """
        )

        transfer_id = getattr(context, attr_name)

        template = f"""
        Given the field "transfer_id" with value "{transfer_id}"
        And I use the token of the user with id "{line['user_id_to']}"
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
