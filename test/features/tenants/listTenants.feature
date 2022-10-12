@old
@api.tenants
@listTenants
@sanity
Feature: Tenants API - listTenants

    As an admin
    I want to list all the tenants details


    @authorization
    Scenario: Validate response for guest user
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there is 1 tenant
        And I use a tenant's token
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for admin user
        Given there is 1 tenant
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"


    Scenario: List tenants
        Given there are 5 tenants
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant-list"
        And the Api response contains the expected data
            | skip_param |
            | api_token  |
