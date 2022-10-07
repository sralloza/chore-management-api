from behave import *


@given("I create a flat")
def step_impl(context):
    context.execute_steps(
        """
        Given I use the admin token
        When I send a request to the Api resource "requestFlatCreateCode"
        Then the response status code is "200"
        And I save the "code" attribute of the response as "create_code"
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "200"
        And I clear the "create_code" attribute of the context
        And I clear the token
        """
    )

@given("I create a flat with a user")
def step_impl(context):
    context.execute_steps(
        """
        Given I create a flat
        """
    )
