Feature: Weekly Chores API - deleteWeeklyChores
    Scenario: Delete a weekly chore
        Given there is 1 tenant
        And there is 1 chore type
        And I create the weekly chores for the week "2022.01" using the API
        When I delete the weekly chores for the week "2022.01" using the API
        Then the response status code is "204"
        And The Api response is empty
        And the database contains the following weekly chores


    Scenario: Validate error when deleting an unknown weekly chore
        When I delete the weekly chores for the week "2022.01" using the API
        Then the response status code is "404"
        And the error message is "No weekly chores found for week 2022.01"


    Scenario Outline: Validate error when deleting weekly chores for invalid week
        When I delete the weekly chores for the week "<invalid_week_id>" using the API
        Then the response status code is "400"
        And the error message is "Invalid week ID: <invalid_week_id>"

        Examples: invalid_week_id = <invalid_week_id>
            | invalid_week_id |
            | invalid-week    |
            | 2022-03         |
            | 2022.3          |
            | 2022.00         |
            | 2022.55         |
            | 2022023         |
            | whatever        |
