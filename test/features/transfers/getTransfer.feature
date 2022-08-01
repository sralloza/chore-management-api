@api.transfers
@getTransfer
Feature: Transfers API - getTransfer

    As an admin or tenant
    I want to get the details of a specific transfer

    @authorization
    Scenario: Validate response for guest user
        Given the field "transferId" with value "1"
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Tenant access required"


    @authorization
    Scenario Outline: Validate response for tenant user
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        Then the response status code is "200"
        And I save the "id" attribute of the response as "transferId"
        Given I use the token of the tenant with id "<token_tenant_id>"
        When I send a request to the Api
        Then the response status code is "200"

        Examples: token_tenant_id = <token_tenant_id>
            | token_tenant_id |
            | 1               |
            | 2               |


    @authorization
    Scenario: Validate response for admin user
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        Then the response status code is "200"
        And I save the "id" attribute of the response as "transferId"
        Given I use the token of the tenant with id "2"
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "200"


    Scenario: Get transfer happy path
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And the following transfers are created
            | tenant_id_from | tenant_id_to | chore_type | week_id | accepted | id_attr_name |
            | 1              | 2            | A          | 2022.01 | None     | transferId   |
        And I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And the response contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 2            | A          | 2022.01 | False     | None     |


    Scenario: Get transfer not found
        Given I use the admin token
        When I get the transfer with id "999" using the API
        Then the response status code is "404"
        And the error message is "No transfer found with id 999"
