@api.tenants
@recreateTenantToken
Feature: Tenants API - recreateTenantToken

    Scenario: Recreate tenant token
        Given there is 1 tenant
        And the field "tenantId" with value "1"
        And I use the admin token
        When I send a request to the Api resource "getTenant"
        Then the response status code is "200"
        And I save the "api_token" attribute of the response as "api_token"
        And I clear the token
        Given the field "tenantId" with value "1"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant"
        And the Api response contains the expected data
            | skip_param |
            | api_token  |
        And the response field "api_token" is different than "api_token"
