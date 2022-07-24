@api.tenants
@listTenants
Feature: Tenants API - listTenants

    Scenario: List tenants
        Given there are 5 tenants
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant-list"
        And the Api response contains the expected data
            | skip_param |
            | api_token  |
