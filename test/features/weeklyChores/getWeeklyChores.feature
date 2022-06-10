Feature: Weekly Chores API - getWeeklyChores

    Scenario: Get weekly chores by weekId
        Given there is 1 tenant
        And there is 1 chore type
        And I create the weekly chores for the week "2022.01" using the API
        When I get the weekly chores for the week "2022.01" using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore"
        And the response contains the following weekly chores
            | week_id | A |
            | 2022.01 | 1 |


    Scenario Outline: Validate error when trying to get weekly chores by an invalid weekId
        When I get the weekly chores for the week "<invalid_week_id>" using the API
        Then the response status code is "400"
        And the error message contains "Invalid week ID: <invalid_week_id>"

        Examples: Invalid week IDs
            | invalid_week_id |
            | invalid-week    |
            | 2022-03         |
            | 2022.3          |
            | 2022.00         |
            | 2022.55         |
            | 2022023         |
            | whatever        |
