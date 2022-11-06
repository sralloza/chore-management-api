from json import dumps, loads
from pathlib import Path

from requests import Response
from toolium.utils.dataset import map_param

from common.utils import replace_nested_ob


def get_step_body_json(context):
    text = map_param(context.text)
    body_params = loads(text) if isinstance(context.text, str) else context.text
    if isinstance(body_params, (dict, list)):
        replace_nested_ob(body_params)
    return body_params


def register_response(context, res: Response):
    folder = (
        Path(__file__).parent.parent / "output" / "responses" / context.operation_id
    )
    folder.mkdir(parents=True, exist_ok=True)

    file_name = f"{context.correlator}.json"
    file = folder / file_name

    try:
        if not res.request.body:
            req_body = None
        else:
            req_body_str = res.request.body.decode("utf-8")
            req_body = loads(req_body_str)
    except Exception:
        req_body = str(res.request.body)

    info = {
        "req": {
            "url": res.request.url,
            "method": res.request.method,
            "correlator": context.correlator,
            "headers": dict(res.request.headers),
            "body": req_body,
        },
        "res": {
            "url": res.url,
            "status_code": res.status_code,
            "is_error": not res.ok,
            "headers": dict(res.headers),
            "body": res.json() if res.text else None,
            "elapsed": res.elapsed.total_seconds(),
        },
    }

    file.write_text(dumps(info, indent=2))
