@chore-type
@crud.delete
Feature: Chore Types API - deleteChoreType

    As an admin I want to delete a specific chore type.

    # TODO: validate only admin have access (guests and tenants are not allowed)


    Scenario: delete chore type
        Given there is 1 chore type
        When I delete the chore type with id "A" using the API
        Then the response status code is "204"
        And the database contains the following chore types


    Scenario: validate error when deleting a non existing chore type
        When I delete the chore type with id "invalid" using the API
        Then the response status code is "404"
        And the error message is "No chore type found with id invalid"
