import requests
from prometheus_client.parser import text_string_to_metric_families

from common.utils import URL

METRICS_URL = URL + "/metrics"


def get_metrics():
    # TODO: use api.send_request() instead
    # Warning: needs context
    res = requests.get(METRICS_URL)
    res.raise_for_status()
    return tuple(text_string_to_metric_families(res.text))


def apply_labels_filter(metric, labels):
    if not labels:
        return True
    for key, value in labels.items():
        if metric.labels.get(key) != value:
            return False
    return True


def get_counter(metric_name: str, metrics=None, *, labels=None):
    metrics = metrics or get_metrics()

    for family in metrics:
        if family.name == metric_name:
            if len(family.samples) == 0:
                raise ValueError(f"Metric {metric_name} has no samples")
            if family.type == "histogram":
                return sum(
                    x.value
                    for x in family.samples
                    if x.name == metric_name + "_count"
                    and apply_labels_filter(x, labels)
                )
            if family.type == "counter":
                return sum(x.value for x in family.samples)
            raise ValueError("What is happening here?")
    raise ValueError(f"Metric {metric_name!r} not found")
