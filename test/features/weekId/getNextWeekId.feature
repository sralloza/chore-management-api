@api.week-id
@getNextWeekId
Feature: Week ID API - getNextWeekId

    As an admin, tenant or guest I want to get the next week id.

    Scenario: Get next week ID
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "week-id"
        And the response attribute "week_id" as string is "[NOW(%Y.%W) + 7 DAYS]"
