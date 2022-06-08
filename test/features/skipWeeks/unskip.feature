Feature: Weekly Chores API - skipWeek

    As a tenant I want to unskip a week in case I have wrongly skipped it.

    # Note: more detailed scenarios are described in the createWeeklyChores feature
    Scenario: a tenant unskips a single week
        Given there are 3 tenants
        And there are 3 chore types
        And the tenant 2 skips the week "2025.01" using the API
        When the tenant 2 unskips the week "2025.01" using the API
        Then the response status code is "204"
        And I create the weekly chores for the week "2025.01" using the API
        And I list the weekly chores using the API
        And the response contains the following weekly chores
            """
            type     A  B  C

            2025.01  1  2  3
            """


    Scenario: validate error when tenants unskips a non skipped week
        Given there is 1 tenant
        When the tenant 1 unskips the week "2022.01" using the API
        Then the response status code is "400"
        And the error message is "Tenant tenant1 has not skipped the week 2022.01"

    Scenario Outline: Validate error when tenants unskips an invalid week
        Given there is 1 tenant
        When the tenant 1 unskips the week "<invalid_week_id>" using the API
        Then the response status code is "400"
        And the error message is "Invalid week ID: <invalid_week_id>"

        Examples: Invalid week IDs
            | invalid_week_id |
            | invalid-week    |
            | 2022-03         |
            | 2022.3          |
            | 2022.00         |
            | 2022.55         |
            | 2022023         |
            | whatever        |
