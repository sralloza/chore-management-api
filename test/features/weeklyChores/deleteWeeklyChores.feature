@api.weekly-chores
@deleteWeeklyChores
Feature: Weekly Chores API - deleteWeeklyChores
    Scenario: Delete a weekly chore
        Given there is 1 tenant
        And there is 1 chore type
        And I create the weekly chores for the week "2022.01" using the API
        And the field "weekId" with string value "2022.01"
        When I send a request to the Api
        Then the response status code is "204"
        And The Api response is empty
        And the database contains the following weekly chores


    Scenario: Validate error when deleting an unknown weekly chore
        Given the field "weekId" with string value "2022.01"
        When I send a request to the Api
        Then the response status code is "404"
        And the error message is "No weekly chores found for week 2022.01"


    Scenario Outline: Validate error when deleting weekly chores for invalid week
        Given the field "weekId" with string value "<invalid_week_id>"
        When I send a request to the Api
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
