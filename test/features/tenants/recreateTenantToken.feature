@tenants
Feature: Tenants API - recreateTenantToken

    Scenario: Recreate tenant token
        Given there is 1 tenant
        When I get the tenant with id "1" using the API
        And I save the tenant's token
        And I recreate the token of the tenant with id "1" using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant"
        And the tenant's token is different from the saved token
