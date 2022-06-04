from uuid import uuid4

from behave import step


@step("there is {tenants:d} tenant")
@step("there are {tenants:d} tenants")
def step_impl(context, tenants):
    for i in range(1, tenants + 1):
        payload = {
            "telegram_id": i,
            "username": f"user{i}",
            "api_token": str(uuid4()),
        }

        context.res = context.post("/tenants", json=payload)
        context.execute_steps('Given the response status code is "200"')
    context.res = None
