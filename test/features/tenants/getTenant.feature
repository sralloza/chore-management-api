@api.tenants
@getTenant
Feature: Tenants API - getTenant

    As a tenant or admin
    I want to access a tenant's detail or I want to access myself's details

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


    Scenario Outline: Get tenant by id
        Given there is 1 tenant
        And I use the token of the tenant with id "<tenant_token_from>"
        And the field "tenantId" with value "<id>"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "simple-tenant"
        And the Api response contains the expected data

        Examples: id = <id> | tenant_token_from = <tenant_token_from>
            | id | tenant_token_from |
            | 1  | 1                 |
            | 1  | admin             |
            | me | 1                 |


    Scenario Outline: Validate error response when using keyword me with the admin token
        Given I use the admin token
        And the field "tenantId" with value "1"
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


    Scenario: Validate error when requesting non existing tenant
        Given the field "tenantId" with value "2"
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "404"
        And the error message is "No tenant found with id 2"
