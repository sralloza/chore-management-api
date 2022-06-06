Feature: Weekly Chores API - listWeeklyChores

    Scenario: list weekly chores
        Given there is 1 tenant
        And there is 1 chore type
        And I create the weekly chores for the following weeks using the API
            | week_id |
            | 2022.01 |
            | 2022.02 |
            | 2022.03 |
        When I list the weekly chores using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore-list"
        And the response contains the following weekly chores
            """
            type     A

            2022.01  1
            2022.02  1
            2022.03  1
            """
