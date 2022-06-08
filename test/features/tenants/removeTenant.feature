Feature: Tenants API - deleteTenant

    Scenario: Delete tenant
        Given I create a tenant using the API
            | username | tenant_id |
            | John     | 111       |
        When I delete the tenant with id 111 using the API
        Then the response status code is "204"
        And a tenant with id 111 is not in the tenants list response


    Scenario: Validate error removing a non-existing tenant
        When I delete the tenant with id 111 using the API
        Then the response status code is "404"
        And the error message is "No tenant found with id 111"
