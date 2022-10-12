@old
@api.chore-type
@listChoreTypes
@sanity
Feature: Chore Types API - listChoreTypes

    As an admin or tenant
    I want to list the defined chore types


    @authorization
    Scenario: Validate response for guest user
        When I send a request to the Api
        Then the response status code is "403"


    @authorization
    Scenario: Validate response for tenant user
        Given there is 1 chore type
        And I use a tenant's token
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for admin user
        Given there is 1 chore type
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"

    Scenario: List chore types when empty
        Given I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type-list"
        And the Api response contains the expected data
            """
            []
            """


    Scenario: List chore types when non empty
        Given there are 4 chore types
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type-list"
        And the Api response contains the expected data
