from behave import *
from hamcrest import *

from common.metrics import *


@given("I save the current metrics")
def step_impl(context):
    context.metrics = get_metrics()


@then('the metric "{metric}" has not changed')
def step_impl(context, metric):
    old_metric = get_metric_sum(metric, context.metrics)
    new_metric = get_metric_sum(metric)

    assert_that(new_metric, equal_to(old_metric))


@then('the metric "{metric}" has been incremented by {number:d}')
def step_impl(context, metric, number):
    old_metric = get_metric_sum(metric, context.metrics)
    new_metric = get_metric_sum(metric)

    assert_that(new_metric, equal_to(old_metric + number))
