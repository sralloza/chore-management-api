from behave import *


@given("I request a flat create code")
def step_impl(context):
    context.execute_steps(
        """
        Given I use the admin API key
        When I send a request to the Api resource "requestFlatCreateCode"
        Then the response status code is "200"
        And I save the "code" attribute of the response as "create_code"
        And I clear the token
    """
    )
