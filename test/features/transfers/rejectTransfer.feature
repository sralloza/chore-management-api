@old
@api.transfers
@rejectTransfer
@sanity
Feature: Transfers API - rejectTransfer

    As a tenant
    I want to reject a chore transfer other tenant sent me


    @authorization
    Scenario: Validate response for guest user
        Given the field "transferId" with value "1"
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Tenant access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And the following transfers are created
            | tenant_id_from | tenant_id_to | chore_type | week_id | accepted |
            | 1              | 2            | A          | 2022.01 | None     |
        Then the response status code is "200"
        And I save the "id" attribute of the response as "transferId"
        Given I use the token of the tenant with id "2"
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for admin user
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And the following transfers are created
            | tenant_id_from | tenant_id_to | chore_type | week_id | accepted |
            | 1              | 2            | A          | 2022.01 | None     |
        Then the response status code is "200"
        And I save the "id" attribute of the response as "transferId"
        Given I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"


    Scenario: Validate error response when requesting other tenant's data
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And the following transfers are created
            | tenant_id_from | tenant_id_to | chore_type | week_id | accepted |
            | 1              | 2            | A          | 2022.01 | None     |
        And I save the "id" attribute of the response as "transferId"
        Given I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "You don't have permission to access other tenant's data"


    Scenario: Reject chore transfer happy path
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And the following transfers are created
            | tenant_id_from | tenant_id_to | chore_type | week_id | accepted |
            | 1              | 2            | A          | 2022.01 | None     |
        And I save the "id" attribute of the response as "transferId"
        And I use the token of the tenant with id "2"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And the database contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 2            | A          | 2022.01 | True      | False    |
        And the database contains the following weekly chores
            | week_id | A | B | C |
            | 2022.01 | 1 | 2 | 3 |
        And the database contains the following tickets
            | tenant  | A | B | C |
            | tenant1 | 0 | 0 | 0 |
            | tenant2 | 0 | 0 | 0 |
            | tenant3 | 0 | 0 | 0 |


    @timing
    Scenario: Validate transfer timestamp after transfer is rejected
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And the following transfers are created
            | tenant_id_from | tenant_id_to | chore_type | week_id | accepted |
            | 1              | 2            | A          | 2022.01 | None     |
        And I save the "id" attribute of the response as "transferId"
        And I use the token of the tenant with id "2"
        When I send a request to the Api
        Then the response status code is "200"
        And the response timestamp attribute is at most "50" ms ago


    Scenario: Validate error response when rejecting a chore transfer twice
        Given there are 3 tenants
        And there are 3 chore types
        And I create the weekly chores for the week "2022.01" using the API
        And the following transfers are created
            | tenant_id_from | tenant_id_to | chore_type | week_id | accepted |
            | 1              | 2            | A          | 2022.01 | None     |
        And I save the "id" attribute of the response as "transferId"
        And I use the token of the tenant with id "2"
        When I send a request to the Api
        Then the response status code is "200"
        When I send a request to the Api
        Then the response status code is "400"
        And the error message contains "Transfer with id .+ already completed"


    Scenario: Validate error response when rejecting a chore transfer with invalid transfer_id
        Given I use the admin API key
        And the field "transferId" with value "999"
        When I send a request to the Api
        Then the response status code is "404"
        And the error message is "No transfer found with id 999"
