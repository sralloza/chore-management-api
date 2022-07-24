from json import loads

from common.utils import replace_nested_ob


def get_step_body_json(context):
    body_params = loads(context.text) if isinstance(context.text, str) else context.text
    if isinstance(body_params, (dict, list)):
        replace_nested_ob(body_params)
    return body_params
