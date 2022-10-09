@api.flats
@requestFlatCreateCode
Feature: Flats API - requestFlatCreateCode

    As an admin
    I want to get a code for creating a flat


    @authorization
    Scenario: Validate response for guest
        When I send a request to the Api
        Then the response status code is "401"
        And the response status code is defined
        And the error message is "Missing API key"


    @authorization
    Scenario: Validate response for user
        Given I create a flat with a user
        And I use the user API key
        When I send a request to the Api
        Then the response status code is "403"
        And the response status code is defined
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for flat admin
        Given I create a flat
        And I use the flat API key
        When I send a request to the Api
        Then the response status code is "403"
        And the response status code is defined
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for admin
        Given I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"


    Scenario: Request flat create code
        Given I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema
