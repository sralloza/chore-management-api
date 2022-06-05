from behave import step

from common.week_id import *
from common.weekly_chores import *


@step("I list the weekly chores using the API")
def step_impl(context):
    context.res = context.get("/weekly-chores")


@step('I get the weekly chores for the week "{week_id}" using the API')
def step_impl(context, week_id):
    context.res = context.get(f"/weekly-chores/{week_id}")


@step('I create the weekly chores for the week "{week_id}" using the API')
@step("I create the weekly chores for the following weeks using the API")
def step_impl(context, week_id=None):
    if week_id:
        weeks = [week_id]
    else:
        weeks = [x["week_id"] for x in context.table]

    if len(weeks) == 1:
        context.res = context.post(f"/weekly-chores/week/{weeks[0]}")
        return

    for week_id in weeks:
        res = context.post(f"/weekly-chores/week/{week_id}")
        err_msg = f"Failed to create weekly chores for week {week_id} ({res.status_code}): {res.text}"
        assert res.ok, err_msg


@step('the tenant {tenant_id:d} skips the week "{week_id}" using the API')
def step_impl(context, tenant_id, week_id):
    context.res = context.post(f"/weekly-chores/skip/{week_id}/tenant/{tenant_id}")


@step("I create the weekly chores for next week using the API")
def step_impl(context):
    context.res = context.post("/weekly-chores")


@step('I delete the weekly chores for the week "{week_id}" using the API')
def step_impl(context, week_id):
    context.res = context.delete(f"/weekly-chores/{week_id}")


@step("the response contains the following weekly chores")
def step_impl(context):
    actual = parse_weekly_chores_res_table_str(context.res)
    if "{next}" in context.text:
        context.text = context.text.replace("{next}", calculate_next_week_id())
    expected = context.text

    msg = f"tables don't match:\n\n{expected}\n\n{actual}"
    assert expected == actual, msg
