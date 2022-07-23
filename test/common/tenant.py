from collections import namedtuple
from unittest import mock

from common.utils import parse_table

Tenant = namedtuple("Tenant", "username tenant_id api_token")


def get_tenants_from_feature_table(context):
    return [_get_tenant_from_row(x) for x in parse_table(context.table)]


def _get_tenant_from_row(row):
    username = row.get("username", mock.ANY)
    tenant_id = row["tenant_id"]
    return Tenant(username, tenant_id, mock.ANY)


def get_tenants_from_response(context):
    context.execute_steps("Given the response body is a valid json")
    res_json = context.res.json()

    if not isinstance(res_json, list):
        return [Tenant(**res_json)]
    return [Tenant(**x) for x in context.res.json()]
