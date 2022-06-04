from behave import step

# from common.week_id import calculate_next_week_id
from common.weekly_chores import parse_weekly_chores_res_table_str


@step("I get the weekly chores through the API")
def step_imp(context):
    context.res = context.get("/weekly-chores")


@step("I create the following weekly chores through the API")
def step_impl(context):
    weeks = [x["week_id"] for x in context.table]
    if len(weeks) == 1:
        context.res = context.post(f"/weekly-chores/week/{weeks[0]}")
        return

    for week_id in weeks:
        res = context.post(f"/weekly-chores/week/{week_id}")
        context.res_list.append(res)


@step("I create the weekly chores for next week through the API")
def step_impl(context):
    context.res = context.post("/weekly-chores")


@step('I remove the weekly chores for the week "{week_id}" trough the API')
def step_impl(context, week_id):
    context.res = context.delete(f"/weekly-chores/{week_id}")


@step("There should be the following weekly chores")
def step_imp(context):
    actual = parse_weekly_chores_res_table_str(context.res)
    if "{next}" in context.text:
        context.text = context.text.replace("{next}", calculate_next_week_id())
    expected = context.text

    msg = f"tables don't match:\n\n{expected}\n\n{actual}"
    assert expected == actual, msg
