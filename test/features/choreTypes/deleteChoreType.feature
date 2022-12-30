@old
@api.chore-types
@deleteChoreType
@old
Feature: Chore Types API - deleteChoreType

    As an admin
    I want to delete a specific chore type


    @authorization
    Scenario: Validate response for guest user
        When I send a request to the Api
        Then the response status code is "401"
        And the error message is "Missing API key"


    @authorization
    Scenario: Validate response for user
        Given there is 1 chore type
        And I create a user and I use the user API key
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for admin user
        Given there is 1 chore type
        And I use the admin API key
        And the field "chore_type_id" with value "ct-a"
        When I send a request to the Api
        Then the response status code is "204"


    Scenario: Delete chore type
        Given there is 1 chore type
        And I use the admin API key
        And the field "chore_type_id" with value "ct-a"
        When I send a request to the Api
        Then the response status code is "204"
        And the Api response is empty
        When I send a request to the Api resource "listChoreTypes"
        Then the response status code is "200"
        And the Api response contains the expected data
            """
            []
            """


    Scenario: Validate error response when deleting a non existing chore type
        Given the field "chore_type_id" with value "invalid"
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "404"
        And the error message is "ChoreType with id=invalid does not exist"


    Scenario: Validate error response when deleting a chore type with pending chores
        Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
        And I create the weekly chores for the week "2022.02" using the API
        And the field "chore_type_id" with value "ct-a"
        Given I use the admin API key
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Can't delete chore type with active chores"


    @skip
    Scenario: Validate error response when deleting a chore type with non balanced tickets
        Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
        And the following transfers are created
            | user_id_from | user_id_to | chore_type | week_id | accepted |
            | user-1       | user-2     | ct-a       | 2022.01 | True     |
        And the field "chore_type_id" with value "ct-a"
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Chore type has unbalanced tickets"
