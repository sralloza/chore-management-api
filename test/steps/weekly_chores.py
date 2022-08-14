from behave import *

from common.utils import *
from common.weekly_chores import *


@step(
    'I create the weekly chores for the week "{week_id}" with force={force} using the API'
)
@given('I create the weekly chores for the week "{week_id}" using the API')
@given("I create the weekly chores for the following weeks using the API")
def step_impl(context, week_id=None, force=None):
    if force is not None:
        context.execute_steps(
            f"""
            Given the parameters to filter the request
                | param_name | param_value |
                | force      | {force}     |
            """
        )

    if week_id:
        weeks = [week_id]
    else:
        weeks = [x["week_id"] for x in context.table]

    for week_id in weeks:
        context.execute_steps(
            f"""
            Given the field "weekId" with string value "{week_id}"
            And I use the admin token
            When I send a request to the Api resource "createWeeklyChores"
            Then the response status code is "200"
            And I clear the token
            """
        )


@step("the response contains the following weekly chores")
def step_impl(context):
    context.execute_steps("Given the response body is a valid json")
    actual = parse_weekly_chores_res_table_str(context.res)
    expected = parse_table(context.table, attrs=["week_id"], infer_param_type=False)

    for line in expected:
        line["week_id"] = str(line["week_id"])
    assert_arrays_equal(expected, actual)


@step("the database contains the following weekly chores")
def step_impl(context):
    context.execute_steps(
        f"""
        Given I use the admin token
        When I send a request to the Api resource "listWeeklyChores"
        Then the response status code is "200"
        And the response contains the following weekly chores
        {table_to_str(context.table, replace=True, infer=False)}
        """
    )
