from json import loads

from common.utils import replace_nested_ob


def get_step_body_json(context):
    body_params = loads(context.text) if isinstance(context.text, str) else context.text
    if isinstance(body_params, (dict, list)):
        replace_nested_ob(body_params)
    return body_params


def remove_attributes(obj, attrs):
    for attr in attrs:
        remove_attribute(obj, attr)


def remove_attribute(obj, attr):
    if not isinstance(obj, list):
        _remove_attribute(obj, attr)
    else:
        for item in obj:
            remove_attribute(item, attr)


def _remove_attribute(obj, attr):
    attrs = attr.split(".")
    tmp = obj
    for attr in attrs:
        if attr != attrs[-1]:
            tmp = tmp[attr]
        else:
            del tmp[attr]
