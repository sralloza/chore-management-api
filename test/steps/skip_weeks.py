from behave import step
from toolium.utils.dataset import replace_param


@step('the tenant with id "{tenant_id:d}" unskips the week "{week_id}" using the API')
def step_impl(context, tenant_id, week_id):
    week_id = replace_param(week_id, infer_param_type=False)
    context.res = context.post(f"/tenants/{tenant_id}/unskip/{week_id}")
