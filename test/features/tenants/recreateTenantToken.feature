@api.tenants
@recreateTenantToken
Feature: Tenants API - recreateTenantToken

    As an admin or tenant
    I want to recreate a tenant's token

    @authorization
    Scenario: Validate response for guest user
        Given the field "tenantId" with value "1"
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Tenant access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there is 1 tenant
        And the field "tenantId" with value "1"
        And I use a tenant's token
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for admin user
        Given there is 1 tenant
        And the field "tenantId" with value "1"
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "200"


    Scenario: Recreate tenant token
        Given there is 1 tenant
        And the field "tenantId" with value "1"
        And I use the admin token
        When I send a request to the Api resource "listTenants"
        Then the response status code is "200"
        And I save the "api_token" attribute of the response with "tenant_id=1" as "api_token"
        And I clear the token
        Given the field "tenantId" with value "1"
        And I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant"
        And the Api response contains the expected data
            | skip_param |
            | api_token  |
        And the response field "api_token" is different than "api_token"

    Scenario: Validate error response when using keyword me with the admin token
        Given there is 1 tenant
        And I use the admin token
        And the field "tenantId" with value "me"
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Cannot use keyword me with an admin token"


    Scenario: Validate error response when requesting other tenant's data
        Given there are 2 tenants
        And I use the token of the tenant with id "1"
        And the field "tenantId" with value "2"
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "You don't have permission to access other tenant's data"

