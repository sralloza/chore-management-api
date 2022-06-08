Feature: Tenants API - recreateTenantToken

    Scenario: Recreate tenant token
        Given I create a tenant using the API
            | username | tenant_id |
            | John     | 111       |
        When I get the tenant with id 111 using the API
        And I save the tenant's token
        And I recreate the token of the tenant with id 111 using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant"
        And the tenant's token is different from the saved token
        And I save the tenant's token
        And I get the tenant with id 111 using the API
        And the tenant's token is equal to the saved token
