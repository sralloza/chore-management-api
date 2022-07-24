@api.tenants
@getTenant
Feature: Tenants API - getTenant

    Scenario: Get tenant by id
        Given there is 1 tenant
        Given the field "tenantId" with value "1"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant"
        And the response contains the following tenants
            | username | tenant_id |
            | tenant1  | 1         |


    Scenario: Validate error when requesting non existing tenant
        Given the field "tenantId" with value "2"
        When I send a request to the Api
        Then the response status code is "404"
        And the error message is "No tenant found with id 2"
