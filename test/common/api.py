import json
from uuid import uuid4

from common.common import VERSIONED_URL_TEMPLATE


def _format_params(**kwargs):
    params_text = ""
    if "params" in kwargs and kwargs.get("params") is not None:
        params_text = "?"
        for key, value in kwargs.get("params", {}).items():
            params_text += f"{key}={value}&"
        params_text = params_text[:-1]
    return params_text


def request(context, method, path, **kwargs):
    url = VERSIONED_URL_TEMPLATE.format(version=1) + path

    pprint = print
    if "silenced" in kwargs:
        silenced = kwargs.pop("silenced")
        if silenced is True:
            pprint = lambda *x: x

    correlator = str(uuid4())
    pprint("X-Correlator".center(len(correlator), "="))
    pprint(correlator)

    params_text = _format_params(**kwargs)

    pprint(f"\n{method} {path}{params_text}")
    if "json" in kwargs:
        pprint(f">>>> {json.dumps(kwargs['json'])}")

    headers = kwargs.pop("headers", {})
    headers["X-Correlator"] = correlator
    kwargs["headers"] = headers

    res = context.session.request(method, url, **kwargs)
    pprint(f"<<<< {res.status_code} {res.text}\n\n")

    return res
