Feature: Tenants API - skipWeek

    As a tenant, some weeks I may not be living in the apartment so
    I don't have to clean it.

    # Note: more detailed scenarios are described in the createWeeklyChores feature
    Scenario: a tenant skips a single week
        Given there are 3 tenants
        And there are 3 chore types
        When the tenant 2 skips the week "2025.01" using the API
        Then the response status code is "204"
        And I create the weekly chores for the week "2025.01" using the API
        And I list the weekly chores using the API
        And the response contains the following weekly chores
            """
            type     A    B  C

            2025.01  1  1,3  3
            """


    Scenario: a tenant skips the next week
        Given there are 3 tenants
        And there are 3 chore types
        When the tenant 2 skips the week "[NEXT_WEEK_ID]" using the API
        Then the response status code is "204"
        And I create the weekly chores for next week using the API
        And I list the weekly chores using the API
        And the response contains the following weekly chores
            """
            type     A    B  C

            {next}  1  1,3  3
            """

    @run
    Scenario Outline: Validate error when tenants skips an invalid week
        Given there is 1 tenant
        When the tenant 1 skips the week "<invalid_week_id>" using the API
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

    Scenario: validate error when tenant skips a really past week
        Given there is 1 tenant
        When the tenant 1 skips the week "2022.01" using the API
        Then the response status code is "400"
        And the error message is "Cannot skip a week in the past"


    Scenario: validate error when tenant skips last week
        Given there is 1 tenant
        When the tenant 1 skips the week "[LAST_WEEK_ID]" using the API
        Then the response status code is "400"
        And the error message is "Cannot skip a week in the past"


    Scenario: validate error when tenant skips a week in the past
        Given there is 1 tenant
        When the tenant 1 skips the week "[CURRENT_WEEK_ID]" using the API
        Then the response status code is "400"
        And the error message is "Cannot skip the current week"
