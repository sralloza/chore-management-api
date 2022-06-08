from uuid import uuid4
import requests
from toolium.behave.environment import after_all as tlm_after_all
from toolium.behave.environment import after_feature as tlm_after_feature
from toolium.behave.environment import after_scenario as tlm_after_scenario
from toolium.behave.environment import before_all as tlm_before_all
from toolium.behave.environment import before_feature as tlm_before_feature
from toolium.behave.environment import before_scenario as tlm_before_scenario

from common.common import VERSIONED_URL_TEMPLATE
from common.reset import reset_databases


def before_all(context):
    tlm_before_all(context)


def before_feature(context, feature):
    tlm_before_feature(context, feature)


def request(context, method, path, **kwargs):
    url = VERSIONED_URL_TEMPLATE.format(version=1) + path

    pprint = print
    if "silenced" in kwargs:
        silenced = kwargs.pop("silenced")
        if silenced is True:
            pprint = lambda *x: x

    pprint()
    if "json" in kwargs:
        pprint(f"Sending json: {kwargs['json']}\n")

    correlator = str(uuid4())
    headers = kwargs.pop("headers", {})
    headers["X-Correlator"] = correlator
    kwargs["headers"] = headers

    res = context.session.request(method, url, **kwargs)

    pprint("X-Correlator".center(len(correlator), "="))
    pprint(correlator + "\n")
    return res


def before_scenario(context, scenario):
    tlm_before_scenario(context, scenario)
    context.session = requests.Session()

    context.get = lambda path, **kwargs: request(context, "GET", path, **kwargs)
    context.post = lambda path, **kwargs: request(context, "POST", path, **kwargs)
    context.put = lambda path, **kwargs: request(context, "PUT", path, **kwargs)
    context.delete = lambda path, **kwargs: request(context, "DELETE", path, **kwargs)

    context.res = None
    context.res_list = []
    reset_databases(context)

    context.res = None
    context.res_list = []


def after_scenario(context, scenario):
    tlm_after_scenario(context, scenario)


def after_feature(context, feature):
    tlm_after_feature(context, feature)


def after_all(context):
    tlm_after_all(context)
