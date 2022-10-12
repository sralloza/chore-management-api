@old
@api.transfers
@listTransfers
Feature: Transfers API - listTransfers

    As a admin or tenant
    I want to list the chore transfers

    @authorization
    Scenario: Validate response for guest user
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Tenant access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there is 1 tenant
        And I use a tenant's token
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for admin user
        Given there is 1 tenant
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"


    Scenario: List transfers when database is not empty
        Given there are 4 tenants, 4 chore types and weekly chores for the week "2022.01"
        And the following transfers are created
            | tenant_id_from | tenant_id_to | chore_type | week_id | accepted |
            | 1              | 2            | A          | 2022.01 | True     |
            | 3              | 2            | C          | 2022.01 | False    |
            | 4              | 2            | D          | 2022.01 | None     |
        And I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer-list"
        And the Api response contains the expected data
            | skip_param |
            | id         |
            | timestamp  |


    Scenario: List transfers when database is empty
        Given there is 1 tenant
        And I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer-list"
        And the Api response contains the expected data
            """
            []
            """
