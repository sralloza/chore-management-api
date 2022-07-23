from behave import step

from common.utils import *
from common.week_id import *


@step("I get the next week ID using the API")
def step_impl(context):
    context.res = context.get("/week-id/next")


@step("I get the last week ID using the API")
def step_impl(context):
    context.res = context.get("/week-id/last")


@step("the response weekId is the same as the calculated next weekId")
def step_impl(context):
    actual = get_week_id_from_res(context.res)
    expected = calculate_next_week_id()

    assert_week_id_equals(expected, actual)


@step("the response weekId is the same as the calculated last weekId")
def step_impl(context):
    actual = get_week_id_from_res(context.res)
    expected = calculate_last_week_id()

    assert_week_id_equals(expected, actual)
