Feature: Weekly Chores API - skipWeek

    # Note: more detailed scenarios are described in the createWeeklyChores feature
    Scenario: a tenant skips a single week
        Given there are 3 tenants
        And there are 3 chore types
        When the tenant 2 skips the week "2022.01" using the API
        Then the response status code is "204"
        And I create the weekly chores for the week "2022.01" using the API
        And I list the weekly chores using the API
        And the response contains the following weekly chores
            """
            type     A    B  C

            2022.01  1  1,3  3
            """"
