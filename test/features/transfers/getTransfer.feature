@transfers
@crud.get
Feature: Transfers API - getTransfer

    As an admin or tenant I want to get the details of a specific transfer.

    Scenario: Get transfer happy path
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And the following transfers are created
            | tenant_id_from | tenant_id_to | chore_type | week_id | accepted | id_attr_name |
            | 1              | 2            | A          | 2022.01 | None     | transfer_id  |
        When I get the transfer with id saved as "transfer_id" using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And the response contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 2            | A          | 2022.01 | False     | None     |


    Scenario: Get transfer not found
        When I get the transfer with id "999" using the API
        Then the response status code is "404"
        And the error message is "No transfer found with id 999"
