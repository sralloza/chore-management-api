from behave import *
from hamcrest import *

from common.metrics import *
from common.request import *


@given("I save the current metrics")
def step_impl(context):
    # TODO: if just after starting the app we execute a metrics test, it will fail
    # because the metrics are not yet created
    context.metrics = get_metrics()


@then('the metric counter "{metric}" added has not changed')
def step_impl(context, metric):
    old_metric = get_counter(metric, context.metrics)
    new_metric = get_counter(metric)

    assert_that(new_metric, equal_to(old_metric))


@then('the metric counter "{metric}" added has been incremented by {number:d}')
def step_impl(context, metric, number):
    old_metric = get_counter(metric, context.metrics)
    new_metric = get_counter(metric)

    assert_that(new_metric, equal_to(old_metric + number))


@then('the metric counter "{metric}" added has been incremented by {number:d}')
def step_impl(context, metric, number):
    old_metric = get_counter(metric, context.metrics)
    new_metric = get_counter(metric)

    assert_that(new_metric, equal_to(old_metric + number))


@then('the metric counter "{metric}" has been incremented by {number:d}')
def step_impl(context, metric, number):
    old_metric = get_counter(metric, context.metrics)
    new_metric = get_counter(metric)

    assert_that(new_metric, equal_to(old_metric + number))


@then('the metric counter "{metric}" with labels has been incremented by {number:d}')
def step_impl(context, metric, number):
    labels = table_to_dict(context.table, col_param="label", col_value="value")

    old_metric = get_counter(metric, context.metrics, labels=labels)
    new_metric = get_counter(metric, labels=labels)

    assert_that(new_metric, equal_to(old_metric + number))
