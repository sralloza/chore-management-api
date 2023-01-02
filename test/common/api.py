import re

from requests import Response

from common.openapi import get_current_operation, get_operation
from common.response import register_response
from common.utils import URL, VERSIONED_PATH, VERSIONED_URL_TEMPLATE
from constants import BLACKLISTED_STDOUT_FEATURES


def send_request(context, endpoint=None, payload=None, raw_payload=False):
    if endpoint is None:
        endpoint = context.feature.name.split(" - ")[-1]

    if endpoint is None:
        operation = get_current_operation(context)
    else:
        operation = get_operation(endpoint)

    path = operation["path"]
    is_path_raw = operation.get("rawPath", False)
    method = operation["method"].upper()
    operation_id = operation["operationId"]

    url_params = get_url_params(context, path)
    path = path.format(**url_params)
    context.res = _send_request(
        context, method, path, operation_id, payload, is_path_raw, raw_payload
    )


def get_url_params(context, path):
    param_names = [x.group(1) for x in re.finditer(r"\{(\w+)\}", path) if x]
    if "authorization" in context.tags or "common" in context.tags:
        return {k: getattr(context, k, "xxx") for k in param_names}
    return {k: getattr(context, k) for k in param_names}


def _send_request(
    context,
    method,
    path,
    operation_id,
    payload=None,
    is_path_raw=False,
    raw_payload=False,
):
    if is_path_raw:
        url = URL + path
    else:
        if path.startswith(VERSIONED_PATH.format(version=1)):
            path = path.replace(VERSIONED_PATH.format(version=1), "", 1)
        url = VERSIONED_URL_TEMPLATE.format(version=1) + path

    token = getattr(context, "token", None)
    if token:
        context.headers["x-token"] = token

    params = getattr(context, "params", None)
    kwargs = dict(params=params, timeout=5, headers=context.headers)
    if raw_payload:
        kwargs["data"] = payload
    else:
        kwargs["json"] = payload

    res = context.session.request(method, url, **kwargs)
    if context.operation_id == operation_id:
        # Note: when calling the testing operation multiple times, each request will
        # overwrite the previous one. This is not a problem, as we only care about
        # the last one.
        register_response(context, res)

    if operation_id not in BLACKLISTED_STDOUT_FEATURES:
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
