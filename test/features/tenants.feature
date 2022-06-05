Feature: Tenants API
    Scenario: Create a new tenant
        When I create a tenant with name "John" and id 111
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant"
        And a tenant with name "John" and id 111 is in the tenants list response

    Scenario: Validate error creating a duplicate tenant
        Given I create a tenant with name "John" and id 111
        When I create a tenant with name "John" and id 111
        Then the response status code is "409"
        And the error message is "Tenant with id 111 already exists"
