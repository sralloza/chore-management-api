@tenants
@crud.delete
Feature: Tenants API - deleteTenant

    Scenario: Delete tenant
        Given I create a tenant using the API
            | username | tenant_id |
            | John     | 111       |
        When I delete the tenant with id "111" using the API
        Then the response status code is "204"
        And the database does not contain the following tenants
            | tenant_id |
            | 111       |


    Scenario: Validate error deleting a non-existing tenant
        When I delete the tenant with id "111" using the API
        Then the response status code is "404"
        And the error message is "No tenant found with id 111"


    Scenario: Validate error deleting a tenant with open tasks
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I create the weekly chores for the week "2022.02" using the API
        When I delete the tenant with id "1" using the API
        Then the response status code is "400"
        And the error message is "Tenant has 2 pending chores"


    Scenario: Validate error deleting a tenant with negative tickets
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I transfer a chore using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        When I delete the tenant with id "1" using the API
        Then the response status code is "400"
        And the error message is "Tenant has unbalanced tickets"


    Scenario: Validate error deleting a tenant with positive tickets
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I transfer a chore using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        When I delete the tenant with id "2" using the API
        Then the response status code is "400"
        And the error message is "Tenant has unbalanced tickets"
