from behave import *

from common import *


@given("there is {tenants:d} tenant")
@given("there are {tenants:d} tenants")
def step_impl(context, tenants):
    for i in range(1, tenants + 1):
        payload = {"tenant_id": i, "username": f"tenant{i}"}

        context.res = context.post("/tenants", json=payload)
        context.execute_steps('Then the response status code is "200"')
    context.res = None


@step('I create a tenant with name "{username}" using the API')
@step('I create a tenant with id "{tenant_id:d}" using the API')
@step("I create a tenant using the API")
def step_impl(context, username=None, tenant_id=None):
    tenant_id = tenant_id or context.table[0].get("tenant_id")
    username = username or context.table[0].get("username")

    payload = {}
    if tenant_id is not None:
        payload["tenant_id"] = replace_param(context, tenant_id, infer_param_type=False)
    if username is not None:
        payload["username"] = replace_param(context, username, infer_param_type=False)

    context.res = context.post("/tenants", json=payload)


@when('I create a tenant with body "{body}" using the API')
def step_impl(context, body):
    context.res = context.post("/tenants", json=body)


@when('I get the tenant with id "{tenant_id:d}" using the API')
def step_impl(context, tenant_id):
    context.res = context.get(f"/tenants/{tenant_id}")


@when("I list the tenants using the API")
def step_impl(context):
    context.res = context.get("/tenants")


@step('I delete the tenant with id "{tenant_id:d}" using the API')
def step_impl(context, tenant_id):
    context.res = context.delete(f"/tenants/{tenant_id}")


@when("I save the tenant's token")
def step_impl(context):
    context.execute_steps(
        """
    Given the response body is a valid json
    And the response status code is "200"
    """
    )
    context.api_token = context.res.json()["api_token"]


@when('I recreate the token of the tenant with id "{tenant_id:d}" using the API')
def step_impl(context, tenant_id):
    context.res = context.post(f"/tenants/{tenant_id}/recreate-token")


@then("the response contains the following tenant")
@then("the response contains the following tenants")
def step_impl(context):
    expected_tenants = get_tenants_from_feature_table(context)
    actual_tenants = get_tenants_from_response(context)

    assert_arrays_equal(expected_tenants, actual_tenants)


@then("the response does not contain the following tenants")
def step_impl(context):
    expected_tenants = get_tenants_from_feature_table(context)
    actual_tenants = get_tenants_from_response(context)

    assert_arrays_not_contain(expected_tenants, actual_tenants)


@then("the database contains the following tenants")
def step_impl(context):
    context.execute_steps(
        f"""
    When I list the tenants using the API
    Then the response contains the following tenants
    {table_to_str(context.table)}
    """
    )


@then("the database does not contain the following tenants")
def step_impl(context):
    context.execute_steps(
        f"""
    When I list the tenants using the API
    Then the response does not contain the following tenants
    {table_to_str(context.table)}
    """
    )


@then("the tenant's token is different from the saved token")
def step_impl(context):
    context.execute_steps(
        """
    Given the response body is a valid json
    And the response status code is "200"
    """
    )
    new_token = context.res.json()["api_token"]
    assert (
        new_token != context.api_token
    ), f"{new_token} is the same as {context.api_token}"
