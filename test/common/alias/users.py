from faker import Faker

fake = Faker()


def create_user(context, user_id: str | None = None, username: str | None = None):
    if not user_id:
        username = fake.first_name().lower()
    if not user_id:
        user_id = "".join(fake.random_letters(length=10))

    context.execute_steps(
        f"""
        Given I use the admin API key
        When I send a request to the Api resource "createUser" with body params
          | param_name | param_value |
          | username   | {username}  |
          | id         | {user_id}   |
        Then the response status code is "200"
        When I send a request to the Api resource "listUsers"
        Then the response status code is "200"
        And I clear the token
    """
    )

    key_mapper = {x["id"]: x["api_key"] for x in context.res.json()}
    context.user_api_key = key_mapper[user_id]
    context.created_user_id = user_id
    context.created_user_username = username
