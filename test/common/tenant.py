from collections import namedtuple


Tenant = namedtuple("Tenant", "username telegram_id api_token")


def get_tenants(context):
    return [Tenant(**x) for x in context.get("/tenants").json()]
