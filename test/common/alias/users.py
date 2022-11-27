from faker import Faker

fake = Faker()


def create_user(context):
    username = fake.first_name().lower()
    user_id = "".join(fake.random_letters(length=10))
    context.execute_steps(
        f"""
        Given I use the admin API key
        When I send a request to the Api resource "createUser" with body params
            | param_name | param_value |
            | username   | {username}  |
            | id         | {user_id}   |
        Then the response status code is "200"
        And I save the "api_key" attribute of the response as "user_api_key"
        And I clear the token
    """
    )
    context.created_user_id = user_id
    context.created_user_username = username
