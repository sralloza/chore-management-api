from behave import given, then
from hamcrest import assert_that, equal_to

from common.metrics import get_counter, get_metrics
from common.request import table_to_dict


@given("I save the current metrics")
def step_save_current_metrics(context):
    context.metrics = get_metrics(context)


@then('the metric counter "{metric}" added has not changed')
def step_metric_counter_added_not_changed(context, metric):
    old_metric = get_counter(context, metric, context.metrics)
    new_metric = get_counter(context, metric)

    assert_that(new_metric, equal_to(old_metric))


@then('the metric counter "{metric}" added has been incremented by {number:d}')
def step_metric_counter_added_incremented(context, metric, number):
    old_metric = get_counter(context, metric, context.metrics)
    new_metric = get_counter(context, metric)

    assert_that(new_metric, equal_to(old_metric + number))


@then('the metric counter "{metric}" has been incremented by {number:d}')
def step_metric_counter_incremented(context, metric, number):
    old_metric = get_counter(context, metric, context.metrics)
    new_metric = get_counter(context, metric)

    assert_that(new_metric, equal_to(old_metric + number))


@then('the metric counter "{metric}" with labels has been incremented by {number:d}')
def step_metric_counter_labels_incremented(context, metric, number):
    labels = table_to_dict(context.table, col_param="label", col_value="value")

    old_metric = get_counter(context, metric, context.metrics, labels=labels)
    new_metric = get_counter(context, metric, labels=labels)

    assert_that(new_metric, equal_to(old_metric + number))
