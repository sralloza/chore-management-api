@tenants
@crud.get
Feature: Tenants API - getTenant

    Scenario: Get tenant by id
        Given there is 1 tenant
        When I get the tenant with id "1" using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant"
        And the response contains the following tenants
            | username | tenant_id |
            | tenant1  | 1         |


    Scenario: Validate error when requesting non existing tenant
        When I get the tenant with id "2" using the API
        Then the response status code is "404"
        And the error message is "No tenant found with id 2"
