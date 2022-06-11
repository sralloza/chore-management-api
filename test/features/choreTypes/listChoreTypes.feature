@chore-type
@crud.list
Feature: Chore Types API - listChoreTypes

    As a user I want to list the defined chore types.

    # TODO: validate admin and tenants have access (guest are not allowed)

    Scenario: List chore types when empty
        When I list the chore types using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type-list"
        And the response contains the following chore types


    Scenario: List chore types when non empty
        Given there are 4 chore types
        When I list the chore types using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type-list"
        And the response contains the following chore types
            | id | description  |
            | A  | description1 |
            | B  | description2 |
            | C  | description3 |
            | D  | description4 |
