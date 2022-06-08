from common.common import replace_param


@step('the tenant {tenant_id:d} skips the week "{week_id}" using the API')
def step_impl(context, tenant_id, week_id):
    week_id = replace_param(context, week_id, infer_param_type=False)
    context.res = context.post(f"/skip-weeks/tenant/{tenant_id}/week/{week_id}")


@step('the tenant {tenant_id:d} unskips the week "{week_id}" using the API')
def step_impl(context, tenant_id, week_id):
    week_id = replace_param(context, week_id, infer_param_type=False)
    context.res = context.delete(f"/skip-weeks/tenant/{tenant_id}/week/{week_id}")
