@api.week-id
Feature: Week ID API - getLastWeekId

    As an admin, tenant or guest I want to get the last week id.

    Scenario: Get last week ID
        Given I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "week-id"
        And the response attribute "week_id" as string is "[NOW(%Y.%W) - 7 DAYS]"
