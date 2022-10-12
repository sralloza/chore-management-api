import re
from uuid import uuid4

from requests import Response

from common.openapi import get_current_operation, get_operation
from common.utils import VERSIONED_URL_TEMPLATE


def send_request(context, endpoint=None, payload=None):
    if endpoint is None:
        endpoint = context.feature.name.split(" - ")[-1]

    if endpoint is None:
        operation = get_current_operation(context)
    else:
        operation = get_operation(endpoint)

    path = operation["path"]
    method = operation["method"].upper()

    url_params = get_url_params(context, path)
    path = path.format(**url_params)
    context.res = _send_request(context, method, path, payload)


def get_url_params(context, path):
    param_names = re.findall(r"\{\w+\}", path)
    return {k: getattr(context, k) for k in param_names}


def _send_request(context, method, path, payload=None):
    correlator = str(uuid4())
    url = VERSIONED_URL_TEMPLATE.format(version=1) + path

    headers = getattr(context, "headers", {})
    headers["X-Correlator"] = correlator

    token = getattr(context, "token", None)
    if token:
        headers["x-token"] = token

    params = getattr(context, "params", None)

    res = context.session.request(
        method, url, params=params, json=payload, timeout=5, headers=headers
    )
    print_res(res)
    return res


def print_res(res: Response, length=80):
    print(" REQUEST ".center(length, "="))
    print(f"<<<< {res.request.method} {res.request.url}")
    print(f"<<<< {res.request.headers}")
    if res.request.body:
        print(f"<<<< {res.request.body}")

    print(" RESPONSE ".center(length, "="))
    print(f">>>> {res.status_code} {res.text}")
    if "x-correlator" in res.headers:
        print(f">>>> X-CORRELATOR: {res.headers['x-correlator']}")
    print(f">>>> {res.headers}")

    print("=" * length)
    print("\n")
