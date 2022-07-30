@api.tenants
@createTenant
Feature: Tenants API - createTenant

    As an admin user I want to register a new tenant.

    # TODO: validate only admin have access (guests and tenants are not allowed)

    Scenario: Create a new tenant
        When I send a request to the Api with body params
            | param_name | param_value |
            | username   | John        |
            | tenant_id  | 111         |
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant"
        And the Api response contains the expected data
            | skip_param |
            | api_token  |


    Scenario: Validate error creating a duplicate tenant
        When I send a request to the Api with body params
            | param_name | param_value |
            | username   | John        |
            | tenant_id  | 111         |
        Then the response status code is "200"
        When I send a request to the Api with body params
            | param_name | param_value |
            | username   | John        |
            | tenant_id  | 111         |
        Then the response status code is "409"
        And the error message is "Tenant with id 111 already exists"


    #TODO: return a better error message when the body is not valid
    Scenario Outline: Validate error creating a tenant with invalid body
        When I send a request to the Api with body
            """
            <body>
            """
        Then the response status code is "400"
        And the error message contains "<err_msg>"

        Examples: body = <body> | err_msg = <err_msg>
            | body       | err_msg          |
            | not-a-json | JSON parse error |
            | "string"   | JSON parse error |


    Scenario Outline: Validate error creating a tenant with an invalid tenant_id
        When I send a request to the Api with body params
            | param_name | param_value |
            | username   | John        |
            | tenant_id  | <tenant_id> |
        Then the response status code is "400"
        And one of messages in the errors array is "<err_msg>"

        Examples: tenant_id = <tenant_id> | err_msg = <err_msg>
            | tenant_id | err_msg                    |
            | [NULL]    | tenant_id is required      |
            | [INT:-3]  | tenant_id must be positive |


    Scenario Outline: Validate error creating a tenant with an invalid name
        When I send a request to the Api with body params
            | param_name | param_value |
            | username   | <username>  |
            | tenant_id  | 1           |
        Then the response status code is "400"
        And one of messages in the errors array is "<err_msg>"

        Examples: username = <username> | err_msg = <err_msg>
            | username | err_msg                          |
            | [NULL]   | username is required             |
            | [EMPTY]  | username can't be blank          |
            | po       | username size must be at least 3 |
