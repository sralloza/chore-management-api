from collections import namedtuple
from unittest import mock

from common.common import replace_param

Tenant = namedtuple("Tenant", "username tenant_id api_token")


def get_tenants(context):
    return [Tenant(**x) for x in context.get("/tenants").json()]


def get_tenants_from_feature_table(context):
    return [get_tenant_from_row(context, x) for x in context.table.rows]


def get_tenant_from_row(context, row):
    username = row["username"]
    tenant_id = replace_param(context, row["tenant_id"])
    return Tenant(username, tenant_id, mock.ANY)


def get_tenants_from_response(context):
    context.execute_steps("Given the response body is a valid json")
    res_json = context.res.json()

    if not isinstance(res_json, list):
        return [Tenant(**res_json)]
    return [Tenant(**x) for x in context.res.json()]
