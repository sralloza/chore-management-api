@transfers
@transfers.accept
Feature: Transfers API - acceptTransfer

    As a tenant I want to accept a chore transfer other tenant sent me.

    Scenario: Accept chore transfer happy path
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        And I save the "id" attribute of the response as "transfer_id"
        When a tenant accepts the chore transfer with id saved as "transfer_id" using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And the response contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 2            | A          | 2022.01 | True      | True     |
        And the database contains the following weekly chores
            | week_id | A | B | C |
            | 2022.01 | 2 | 2 | 3 |
        And the database contains the following tickets
            | tenant  | A  | B | C |
            | tenant1 | -1 | 0 | 0 |
            | tenant2 | 1  | 0 | 0 |
            | tenant3 | 0  | 0 | 0 |


    Scenario: Two users exchange tasks
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And the following transfers are created
            | tenant_id_from | tenant_id_to | chore_type | week_id | accepted | id_attr_name  |
            | 1              | 2            | A          | 2022.01 | None     | transfer_id_1 |
            | 2              | 1            | B          | 2022.01 | None     | transfer_id_2 |
        When a tenant accepts the chore transfer with id saved as "transfer_id_1" using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        When a tenant accepts the chore transfer with id saved as "transfer_id_2" using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And the database contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 2            | A          | 2022.01 | True      | True     |
            | 2              | 1            | B          | 2022.01 | True      | True     |
        And the database contains the following weekly chores
            | week_id | A | B | C |
            | 2022.01 | 2 | 1 | 3 |
        And the database contains the following tickets
            | tenant  | A  | B  | C |
            | tenant1 | -1 | 1  | 0 |
            | tenant2 | 1  | -1 | 0 |
            | tenant3 | 0  | 0  | 0 |


    @timing
    Scenario: Validate transfer timestamp after transfer is accepted
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
         And a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        And I save the "id" attribute of the response as "transfer_id"
        When a tenant accepts the chore transfer with id saved as "transfer_id" using the API
        Then the response status code is "200"
        And the response timestamp attribute is at most "20" ms ago


    Scenario: Validate error when accepting a chore transfer twice
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        And I save the "id" attribute of the response as "transfer_id"
        When a tenant accepts the chore transfer with id saved as "transfer_id" using the API
        And a tenant accepts the chore transfer with id saved as "transfer_id" using the API
        Then the response status code is "400"
        And the error message contains "Transfer with id .+ already completed"


    Scenario: Validate error when accepting a chore transfer with invalid transfer_id
        When a tenant accepts the chore transfer with id "999" using the API
        Then the response status code is "404"
        And the error message is "No transfer found with id 999"
