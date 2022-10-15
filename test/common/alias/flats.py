from faker import Faker

fake = Faker()


def create_flat(context, user=False):
    flat_name = "flat-" + fake.word().lower()

    flat_create_instructions = f"""
        Given I use the admin API key
        When I send a request to the Api resource "requestFlatCreateCode"
        Then the response status code is "200"
        And I save the "code" attribute of the response as "create_code"
        When I send a request to the Api resource "createFlat" with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | {flat_name}           |
        Then the response status code is "200"
        And I save the "api_key" attribute of the response as "flat_api_key"
        And I save the "name" attribute of the response as "flat_name"
        And I clear the "create_code" attribute of the context
        And I clear the token
        """

    context.execute_steps(flat_create_instructions)
    if not user:
        return

    username = fake.first_name().lower()
    user_id = fake.bothify("######")
    context.execute_steps(
        f"""
        Given I use the flat API key
        When I send a request to the Api resource "createUser" with body params
            | param_name | param_value |
            | username   | {username}  |
            | user_id    | {user_id}   |
        Then the response status code is "200"
        And I save the "api_key" attribute of the response as "user_api_key"
    """
    )
