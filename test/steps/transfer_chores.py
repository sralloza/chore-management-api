from behave import step

from common import *


@step("a tenant transfers a chore to other tenant using the API")
def step_impl(context):
    context.table.require_columns(
        ["tenant_id_origin", "tenant_id_dest", "chore_type", "week_id"]
    )

    tenant_id_origin = context.table.rows[0]["tenant_id_origin"]
    tenant_id_dest = context.table.rows[0]["tenant_id_dest"]
    chore_type = context.table.rows[0]["chore_type"]
    week_id = context.table.rows[0]["week_id"]

    context.res = context.post(
        "/transfer-chores/from/{}/to/{}/choreType/{}/week/{}".format(
            tenant_id_origin, tenant_id_dest, chore_type, week_id
        )
    )
