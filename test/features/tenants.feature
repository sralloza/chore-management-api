Feature: Tenants API
    Scenario: List tenants
        Given there are 5 tenants
        When I list the tenants using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant-list"
        And the response should contain the following tenants
            | username | telegram_id |
            | tenant1  | [INT:1]     |
            | tenant2  | [INT:2]     |
            | tenant3  | [INT:3]     |
            | tenant4  | [INT:4]     |
            | tenant5  | [INT:5]     |


    Scenario: Create a new tenant
        When I create a tenant with name "John" and id 111 using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant"
        And a tenant with name "John" and id 111 is in the tenants list response


    Scenario: Validate error creating a duplicate tenant
        Given I create a tenant with name "John" and id 111 using the API
        When I create a tenant with name "John" and id 111 using the API
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


    Scenario Outline: Validate error creating a tenant with invalid name
        Given I create a tenant with name "John" and custom id <telegram_id> using the API
        Then the response status code is "400"
        And one of messages in the errors array is "<err_msg>"

        Examples:
            | telegram_id | err_msg                      |
            | [NULL]      | telegram_id is required      |
            | [INT:-3]    | telegram_id must be positive |


    Scenario Outline: Validate error creating a tenant with invalid name
        Given I create a tenant with name "<name>" and id 1 using the API
        Then the response status code is "400"
        And one of messages in the errors array is "<err_msg>"

        Examples:
            | name    | err_msg                          |
            | [NULL]  | username is required             |
            | [EMPTY] | username can't be blank          |
            | po      | username size must be at least 3 |


    Scenario: Remove tenant
        Given I create a tenant with name "John" and id 111 using the API
        When I remove the tenant with id 111 using the API
        Then the response status code is "204"
        And a tenant with id 111 is not in the tenants list response


    Scenario: Validate error removing a non-existing tenant
        When I remove the tenant with id 111 using the API
        Then the response status code is "404"
        And the error message is "No tenant found with id 111"
