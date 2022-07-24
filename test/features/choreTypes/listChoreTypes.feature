@api.chore-type
@listChoreTypes
@sanity
Feature: Chore Types API - listChoreTypes

    As a user I want to list the defined chore types.

    # TODO: validate admin and tenants have access (guest are not allowed)

    Scenario: List chore types when empty
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type-list"
        And the Api response contains the expected data
            """
            []
            """


    Scenario: List chore types when non empty
        Given there are 4 chore types
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type-list"
        And the Api response contains the expected data
