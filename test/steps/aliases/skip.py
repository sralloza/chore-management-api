from random import randint

from behave import *

from common.db import execute_query


@step('I make the tenant "{tenant_id}" skip the week "{week_id}" editing the database')
def step_impl(context, tenant_id, week_id):
    row_id = randint(1, 10**8)
    execute_query(
        "INSERT INTO skipped_weeks (id, week_id, tenant_id) VALUES (%s, %s, %s)",
        (row_id, week_id, tenant_id),
        commit=True,
    )
