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


def before_scenario(context, scenario):
    tlm_before_scenario(context, scenario)
    context.session = requests.Session()

    url = VERSIONED_URL_TEMPLATE.format(version=1)
    context.get = lambda path, **kwargs: context.session.get(url + path, **kwargs)
    context.post = lambda path, **kwargs: context.session.post(url + path, **kwargs)
    context.put = lambda path, **kwargs: context.session.put(url + path, **kwargs)
    context.delete = lambda path, **kwargs: context.session.delete(url + path, **kwargs)

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
