@transfers
@transfers.reject
Feature: Transfers API - rejectTransfer

    As a tenant I want to reject a chore transfer other tenant sent me.

    Scenario: Reject chore transfer happy path
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        And I save the "id" attribute of the response as "transfer_id"
        When a tenant rejects the chore transfer with id saved as "transfer_id" using the API
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


    Scenario: Validate error when rejecting a chore transfer twice
        Given there are 3 tenants
        And there are 3 chore types
        And I create the weekly chores for the week "2022.01" using the API
        And a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        And I save the "id" attribute of the response as "transfer_id"
        When a tenant rejects the chore transfer with id saved as "transfer_id" using the API
        And a tenant rejects the chore transfer with id saved as "transfer_id" using the API
        Then the response status code is "400"
        And the error message contains "Transfer with id .+ already completed"


    Scenario: Validate error when rejecting a chore transfer with invalid transfer_id
        When a tenant rejects the chore transfer with id "999" using the API
        Then the response status code is "404"
        And the error message is "No transfer found with id 999"
