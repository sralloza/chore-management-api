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
