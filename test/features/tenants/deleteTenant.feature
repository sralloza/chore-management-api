@api.tenants
@deleteTenant
Feature: Tenants API - deleteTenant

    Scenario: Delete tenant
        When I send a request to the Api resource "createTenant" with body params
            | param_name | param_value |
            | username   | John        |
            | tenant_id  | 111         |
        Given the field "tenantId" with value "111"
        Then the response status code is "200"
        When I send a request to the Api
        Then the response status code is "204"
        When I send a request to the Api resource "listTenants"
        Then the response status code is "200"
        And the Api response contains the expected data
            """
            []
            """


    Scenario: Validate error deleting a non-existing tenant
        Given the field "tenantId" with value "111"
        When I send a request to the Api
        Then the response status code is "404"
        And the error message is "No tenant found with id 111"


    Scenario: Validate error deleting a tenant with open tasks
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I create the weekly chores for the week "2022.02" using the API
        Given the field "tenantId" with value "1"
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Tenant has 2 pending chores"


    Scenario: Validate error deleting a tenant with negative tickets
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I transfer a chore using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        Given the field "tenantId" with value "1"
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Tenant has unbalanced tickets"


    Scenario: Validate error deleting a tenant with positive tickets
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I transfer a chore using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        Given the field "tenantId" with value "2"
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Tenant has unbalanced tickets"
