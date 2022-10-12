@old
@api.chore-types
@getChoreType
Feature: Chore Types API - getChoreType

    As an admin or tenant
    I want to get the details of a chore type


    @authorization
    Scenario: Validate response for guest user
        Given the field "choreTypeId" with value "A"
        When I send a request to the Api
        Then the response status code is "403"


    @authorization
    Scenario: Validate response for tenant user
        Given there is 1 chore type
        And the field "choreTypeId" with value "A"
        And I use a tenant's token
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for admin user
        Given there is 1 chore type
        And the field "choreTypeId" with value "A"
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"


    Scenario: Get a chore type
        Given there is 1 chore type
        And the field "choreTypeId" with value "A"
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type"
        And the Api response contains the expected data


    Scenario: Validate error response when getting a non existing chore type
        Given the field "choreTypeId" with value "X"
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "404"
        And the error message is "No chore type found with id X"
