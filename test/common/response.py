from json import loads

from toolium.utils.dataset import map_param

from common.utils import replace_nested_ob


def get_step_body_json(context):
    text = map_param(context.text)
    body_params = loads(text) if isinstance(context.text, str) else context.text
    if isinstance(body_params, (dict, list)):
        replace_nested_ob(body_params)
    return body_params
