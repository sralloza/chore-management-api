@api.flats
@listFlats
Feature: Flats API - listFlats

    As an admin
    I want to get a list of flats


    @authorization
    Scenario: Validate response for guest
        When I send a request to the Api
        Then the response status code is "401"
        And the response status code is defined
        And the error message is "Missing API key"


    @authorization
    Scenario: Validate response for user
        Given I create a flat with a user and I use the user API key
        When I send a request to the Api
        Then the response status code is "403"
        And the response status code is defined
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for flat owner
        Given I create a flat and I use the flat API key
        When I send a request to the Api
        Then the response status code is "403"
        And the response status code is defined
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for admin
        Given I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"
        And the response status code is defined


    Scenario: List flats when there are none
        Given I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema
        And the Api response contains the expected data
            """
            []
            """


    Scenario: List flats when there are some
        Given I create a flat
        Given I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema
        And the Api response contains the expected data
            | skip_param |
            | name       |
            | api_key    |
