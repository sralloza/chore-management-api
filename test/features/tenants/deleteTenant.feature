@api.tenants
@deleteTenant
Feature: Tenants API - deleteTenant

    As an admin
    I want to delete a tenant

    @authorization
    Scenario: Validate response for guest user
        Given the field "tenantId" with value "111"
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there is 1 tenant
        And the field "tenantId" with value "1"
        And I use a tenant's token
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for admin user
        Given there is 1 tenant
        And the field "tenantId" with value "1"
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "204"


    Scenario: Delete tenant
        Given I use the admin token
        When I send a request to the Api resource "createTenant" with body params
            | param_name | param_value |
            | username   | John        |
            | tenant_id  | 111         |
        And I clear the token
        Then the response status code is "200"
        Given the field "tenantId" with value "111"
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "204"
        And The Api response is empty
        When I send a request to the Api resource "listTenants"
        Then the response status code is "200"
        And the Api response contains the expected data
            """
            []
            """


    Scenario: Validate error deleting a non-existing tenant
        Given the field "tenantId" with value "111"
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "404"
        And the error message is "No tenant found with id 111"


    Scenario: Validate error deleting a tenant with open tasks
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I create the weekly chores for the week "2022.02" using the API
        Given the field "tenantId" with value "1"
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Tenant has 2 pending chores"


    Scenario: Validate error deleting a tenant with negative tickets
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I transfer a chore using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        Given the field "tenantId" with value "1"
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Tenant has unbalanced tickets"


    Scenario: Validate error deleting a tenant with positive tickets
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I transfer a chore using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        Given the field "tenantId" with value "2"
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Tenant has unbalanced tickets"
