@api.week-id
@getNextWeekId
Feature: Week ID API - getNextWeekId

    As an admin, tenant or guest
    I want to get the next week id


    @authorization
    Scenario: Validate response for guest user
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for tenant user
        Given I use a tenant's token
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for admin user
        Given I use the admin token
        When I send a request to the Api
        Then the response status code is "200"


    Scenario: Get next week ID
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "week-id"
        And the response attribute "week_id" as string is "[NOW(%Y.%W) + 7 DAYS]"
