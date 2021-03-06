import json

from behave import step

from common import *


@step("I list the weekly chores using the API")
def step_impl(context):
    context.res = context.get("/weekly-chores")


@step('I get the weekly chores for the week "{week_id}" using the API')
def step_impl(context, week_id):
    context.res = context.get(f"/weekly-chores/{week_id}")


@step(
    'I create the weekly chores for the week "{week_id}" with force={force} using the API'
)
@step('I create the weekly chores for the week "{week_id}" using the API')
@step("I create the weekly chores for the following weeks using the API")
def step_impl(context, week_id=None, force=None):
    params = None if force is None else {"force": json.loads(force)}

    if week_id:
        weeks = [week_id]
    else:
        weeks = [x["week_id"] for x in context.table]

    if len(weeks) == 1:
        context.res = context.post(f"/weekly-chores/week/{weeks[0]}", params=params)
        return

    for week_id in weeks:
        res = context.post(f"/weekly-chores/week/{week_id}", params=params)
        err_msg = f"Failed to create weekly chores for week {week_id} ({res.status_code}): {res.text}"
        assert res.ok, err_msg


@step("I create the weekly chores for next week with force={force} using the API")
@step("I create the weekly chores for next week using the API")
def step_impl(context, force=None):
    params = None if force is None else {"force": json.loads(force)}

    context.res = context.post("/weekly-chores", params=params)


@step('I delete the weekly chores for the week "{week_id}" using the API')
def step_impl(context, week_id):
    context.res = context.delete(f"/weekly-chores/{week_id}")


@step("the response contains the following weekly chores")
def step_impl(context):
    context.execute_steps("Given the response body is a valid json")
    actual = parse_weekly_chores_res_table_str(context.res)
    expected = parse_table(
        context.table, mode="replace_param", context=context, attrs=["week_id"]
    )
    for line in expected:
        line["week_id"] = str(line["week_id"])
    assert_arrays_equal(expected, actual)


@step("the database contains the following weekly chores")
def step_impl(context):
    context.execute_steps(
        f"""
            When I list the weekly chores using the API
            And the response contains the following weekly chores
            {table_to_str(context.table)}
            """
    )
