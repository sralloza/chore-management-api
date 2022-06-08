Feature: Chore Types API - deleteChoreType
    Scenario: delete chore type
        Given there is 1 chore type
        When I delete the chore type with id A using the API
        Then the response status code is "204"
        And the database contains the following chore types


    Scenario: validate error when deleting a non existing chore type
        When I delete the chore type with id invalid using the API
        Then the response status code is "404"
        And the error message is "No chore type found with id invalid"
