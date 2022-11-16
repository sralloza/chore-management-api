from hamcrest import *
import warnings
from prometheus_client.parser import text_string_to_metric_families

from common.api import send_request
from common.utils import URL

METRICS_URL = URL + "/metrics"


class MetricNotFoundWarning(UserWarning):
    """Metric not found"""


def get_metrics(context):
    send_request(context, "metrics")
    assert_that(context.res.status_code, equal_to(200))
    return tuple(text_string_to_metric_families(context.res.text))


def apply_labels_filter(metric, labels):
    if not labels:
        return True
    for key, value in labels.items():
        if metric.labels.get(key) != value:
            return False
    return True


def get_counter(context, metric_name: str, metrics=None, *, labels=None):
    metrics = metrics or get_metrics(context)

    for family in metrics:
        if family.name == metric_name:
            if len(family.samples) == 0:
                return 0
            if family.type == "histogram":
                return sum(
                    x.value
                    for x in family.samples
                    if x.name == metric_name + "_count"
                    and apply_labels_filter(x, labels)
                )
            if family.type == "counter":
                return sum(x.value for x in family.samples)
            raise ValueError(f"Metric not supported: {family.type}")

    warnings.warn(f"Metric {metric_name} not found", MetricNotFoundWarning)
    return 0
