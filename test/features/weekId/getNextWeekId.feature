@api.week-id
@getNextWeekId
Feature: Week ID API - getNextWeekId

    As a user
    I want to get the next week id


    @authorization
    Scenario: Validate response for guest
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for user
        Given I create a flat with a user
        And I use the user API key
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for flat owner
        Given I create a flat
        And I use the flat API key
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for admin
        Given I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"


    Scenario: Get current week ID
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema
        And the response attribute "week_id" as string is "[NOW(%Y.%W) + 7 DAYS]"
