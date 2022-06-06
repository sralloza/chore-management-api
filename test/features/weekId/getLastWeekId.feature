Feature: Week ID API - getLastWeekId

    Scenario: Get last week ID
        Given I get the last week ID using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "week-id"
        And the response weekId is the same as the calculated last weekId
