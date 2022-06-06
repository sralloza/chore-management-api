Feature: Chore Types API - getChoreType

    Scenario: Get a chore type
        Given there is 1 chore type
        When I get the chore type with id "A" using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type"
        And the response contains the following chore type
            | id | description  |
            | A  | description1 |


    Scenario: Validate error when getting a non existing chore type
        When I get the chore type with id "X" using the API
        Then the response status code is "404"
        And the error message is "No chore type found with id X"

