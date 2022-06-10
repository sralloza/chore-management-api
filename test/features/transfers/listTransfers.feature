@transfers
@crud.list
Feature: Transfers API - listTransfers

    As a tenant/admin I want to list the chore transfers.

    # TODO: guests should not be able to list transfers

    Scenario: List transfers when database is not empty
        Given there are 3 tenants
        And there are 3 chore types
        And I create the weekly chores for the week "2022.01" using the API
        And a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        And I save the "id" attribute of the response as "transfer_id"
        And a tenant completes a chore transfer with id saved as "transfer_id" using the API
        And a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 3              | 2            | C          | 2022.01 |
        When I list the transfers using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer-list"
        And the response contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed |
            | 1              | 2            | A          | 2022.01 | True      |
            | 3              | 2            | C          | 2022.01 | False     |


    Scenario: List transfers when database is empty
        When I list the transfers using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer-list"
        And the response contains the following transfers
