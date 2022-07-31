@api.chore-types
@deleteChoreType
Feature: Chore Types API - deleteChoreType

    As an admin
    I want to delete a specific chore type.


    @authorization
    Scenario: Validate response for guest user
        Given the field "choreTypeId" with value "A"
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there is 1 chore type
        And the field "choreTypeId" with value "A"
        And I use a tenant's token
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for admin user
        Given there is 1 chore type
        And the field "choreTypeId" with value "A"
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "204"


    Scenario: Delete chore type
        Given there is 1 chore type
        And I use the admin token
        And the field "choreTypeId" with value "A"
        When I send a request to the Api
        Then the response status code is "204"
        And The Api response is empty
        When I send a request to the Api resource "listChoreTypes"
        Then the response status code is "200"
        And the Api response contains the expected data
            """
            []
            """


    Scenario: Validate error when deleting a non existing chore type
        Given the field "choreTypeId" with value "invalid"
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "404"
        And the error message is "No chore type found with id invalid"


    Scenario: Validate error when deleting a chore type with pending chores
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I create the weekly chores for the week "2022.02" using the API
        And the field "choreTypeId" with value "A"
        Given I use the admin token
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Chore type A has 2 pending chores"


    Scenario: Validate error when deleting a chore type with non balanced tickets
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I use the admin token
        And I transfer a chore using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        And the field "choreTypeId" with value "A"
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Chore type has unbalanced tickets"
