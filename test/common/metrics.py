import requests
from prometheus_client.parser import text_string_to_metric_families

from common.utils import URL

METRICS_URL = URL + "/metrics"


def get_metrics():
    # TODO: use api.send_request() instead
    # Warning: needs context
    res = requests.get(METRICS_URL)
    res.raise_for_status()
    return text_string_to_metric_families(res.text)


def get_metric_sum(metric_name: str, metrics=None):
    if metrics is None:
        metrics = get_metrics()

    result = 0
    found = False
    for family in metrics:
        for sample in family.samples:
            if sample.name == metric_name:
                result += sample.value
                found = True

    if found:
        return result
    raise ValueError(f"Metric {metric_name!r} not found")
