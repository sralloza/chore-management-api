from hamcrest import *
from prometheus_client.parser import text_string_to_metric_families

from common.api import send_request
from common.utils import URL

METRICS_URL = URL + "/metrics"


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

    # XXX: If the first request we send to the API is a metrics request, then the metrics
    # are not yet available. We should probably check for the length of the response
    # (the first request will return less metrics).
    names = [x.name for x in metrics]
    print(f"Warning: metric {metric_name!r} not found (metrics: {names})")
    return 0
