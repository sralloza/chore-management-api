from collections import namedtuple
from unittest import mock

from toolium.utils.dataset import replace_param

Tenant = namedtuple("Tenant", "username telegram_id api_token")


def get_tenants(context):
    return [Tenant(**x) for x in context.get("/tenants").json()]


def get_tenants_from_feature_table(context):
    return [
        Tenant(x["username"], replace_param(x["telegram_id"]), mock.ANY)
        for x in context.table.rows
    ]


def get_tenants_from_response(context):
    context.execute_steps("Given the response body is a valid json")
    res_json = context.res.json()

    if not isinstance(res_json, list):
        return [Tenant(**res_json)]
    return [Tenant(**x) for x in context.res.json()]
