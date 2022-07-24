@api.chore-types
@getChoreType
Feature: Chore Types API - getChoreType

    As a user I want to get the details of a chore type.

    # TODO: validate admin and tenants have access (guest are not allowed)

    Scenario: Get a chore type
        Given there is 1 chore type
        Given the field "choreTypeId" with value "A"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type"
        And the Api response contains the expected data


    Scenario: Validate error when getting a non existing chore type
        Given the field "choreTypeId" with value "X"
        When I send a request to the Api
        Then the response status code is "404"
        And the error message is "No chore type found with id X"
