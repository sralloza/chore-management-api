Feature: Week ID API - getCurrentWeekId

    As an admin, tenant or guest I want to get the current week id.

    Scenario: Get current week ID
        Given I get the current week ID using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "week-id"
        And the response weekId is the same as the calculated current weekId
