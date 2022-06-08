Feature: Tenants API - createTenant

    As an admin user I want to register a new tenant.

    Scenario: Create a new tenant
        When I create a tenant using the API
            | username | tenant_id |
            | John     | 111       |
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant"
        And the following tenant exists
            | username | tenant_id |
            | John     | 111       |


    Scenario: Validate error creating a duplicate tenant
        Given I create a tenant using the API
            | username | tenant_id |
            | John     | 111       |
        When I create a tenant using the API
            | username | tenant_id |
            | John     | 111       |
        Then the response status code is "409"
        And the error message is "Tenant with id 111 already exists"


    Scenario Outline: Validate error creating a tenant with invalid body
        Given I create a tenant with body "<body>" using the API
        Then the response status code is "400"
        And the error message contains "<err_msg>"

        Examples:
            | body       | err_msg          |
            | not-a-json | JSON parse error |
            | "string"   | JSON parse error |


    Scenario Outline: Validate error creating a tenant with an invalid tenant_id
        Given I create a tenant using the API
            | username |
            | John     |
        Then the response status code is "400"
        And one of messages in the errors array is "<err_msg>"

        Examples:
            | tenant_id | err_msg                      |
            | [NULL]    | tenant_id is required      |
            | [INT:-3]  | tenant_id must be positive |


    Scenario Outline: Validate error creating a tenant with an invalid name
        Given I create a tenant using the API
            | tenant_id |
            | 1         |
        Then the response status code is "400"
        And one of messages in the errors array is "<err_msg>"

        Examples:
            | username | err_msg                          |
            | [NULL]   | username is required             |
            | [EMPTY]  | username can't be blank          |
            | po       | username size must be at least 3 |
