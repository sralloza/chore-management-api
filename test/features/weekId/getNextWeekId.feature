Feature: Week ID API - getNextWeekId

    Scenario: Get next week ID
        Given I get the next week ID using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "week-id"
        And the response weekId is the same as the calculated next weekId
