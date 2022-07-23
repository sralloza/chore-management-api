@api.week-id
Feature: Week ID API - getCurrentWeekId

    As an admin, tenant or guest I want to get the current week id.

    Scenario: Get current week ID
        Given I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "week-id"
        And the response attribute "week_id" as string is "[NOW(%Y.%W)]"
