from behave import step

from common import *


@step('the tenant with id "{tenant_id:d}" skips the week "{week_id}" using the API')
def step_impl(context, tenant_id, week_id):
    week_id = replace_param(context, week_id, infer_param_type=False)
    context.res = context.post(f"/tenants/{tenant_id}/skip/{week_id}")


@step('the tenant with id "{tenant_id:d}" unskips the week "{week_id}" using the API')
def step_impl(context, tenant_id, week_id):
    week_id = replace_param(context, week_id, infer_param_type=False)
    context.res = context.post(f"/tenants/{tenant_id}/unskip/{week_id}")
