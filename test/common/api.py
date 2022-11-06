import re
from json import dumps

from requests import Response

from common.openapi import get_current_operation, get_operation
from common.utils import VERSIONED_URL_TEMPLATE
from metatests.constants import COMMON_SCENARIOS


def send_request(context, endpoint=None, payload=None):
    if endpoint is None:
        endpoint = context.feature.name.split(" - ")[-1]

    if endpoint is None:
        operation = get_current_operation(context)
    else:
        operation = get_operation(endpoint)

    path = operation["path"]
    method = operation["method"].upper()
    operation_id = operation["operationId"]

    url_params = get_url_params(context, path)
    path = path.format(**url_params)
    context.res = _send_request(context, method, path, operation_id, payload)


def get_url_params(context, path):
    param_names = [x.group(1) for x in re.finditer(r"\{(\w+)\}", path) if x]
    scenario_name = context.scenario.name.split(" -- ")[0]
    if scenario_name in COMMON_SCENARIOS:
        return {k: getattr(context, k, "xxx") for k in param_names}
    return {k: getattr(context, k) for k in param_names}


def _send_request(context, method, path, operation_id, payload=None):
    url = VERSIONED_URL_TEMPLATE.format(version=1) + path

    headers = getattr(context, "headers", {})
    headers["X-Correlator"] = context.correlator

    token = getattr(context, "token", None)
    if token:
        headers["x-token"] = token

    params = getattr(context, "params", None)

    res = context.session.request(
        method, url, params=params, json=payload, timeout=5, headers=headers
    )
    if context.operation_id == operation_id:
        context.status_codes.add(res.status_code)
        if not res.ok:
            context.error_messages[res.status_code].add(dumps(res.json()))

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
    print(f">>>> {res.headers}")

    print("=" * length)
    print("\n")
