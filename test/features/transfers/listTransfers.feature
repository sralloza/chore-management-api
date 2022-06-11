@transfers
@crud.list
Feature: Transfers API - listTransfers

    As a tenant/admin I want to list the chore transfers.

    # TODO: guests should not be able to list transfers

    Scenario: List transfers when database is not empty
        Given there are 4 tenants, 4 chore types and weekly chores for the week "2022.01"
        And the following transfers are created
            | tenant_id_from | tenant_id_to | chore_type | week_id | accepted |
            | 1              | 2            | A          | 2022.01 | True     |
            | 3              | 2            | C          | 2022.01 | False    |
            | 4              | 2            | D          | 2022.01 | None     |
        When I list the transfers using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer-list"
        And the response contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 2            | A          | 2022.01 | True      | True     |
            | 3              | 2            | C          | 2022.01 | True      | False    |
            | 4              | 2            | D          | 2022.01 | False     | None     |


    Scenario: List transfers when database is empty
        When I list the transfers using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer-list"
        And the response contains the following transfers
