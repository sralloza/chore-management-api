Feature: Weekly Chores API

    Scenario: Create weekly chores for next week
        Given there is 1 tenant
        And there is 1 chore type
        When I create the weekly chores for next week using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore"
        And the response contains the following weekly chores
            """
            type     A

            {next}  1
            """

    Scenario: Create weekly chores when same number of tenants and chore types
        Given there are 4 tenants
        And there are 4 chore types
        When I create the weekly chores for the following weeks using the API
            | week_id |
            | 2022.01 |
            | 2022.02 |
            | 2022.03 |
            | 2022.04 |
            | 2022.05 |
            | 2022.06 |
            | 2022.07 |
            | 2022.08 |
        And I list the weekly chores using the API
        And the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore-list"
        And the response contains the following weekly chores
            """
            type     A  B  C  D

            2022.01  1  2  3  4
            2022.02  2  3  4  1
            2022.03  3  4  1  2
            2022.04  4  1  2  3
            2022.05  1  2  3  4
            2022.06  2  3  4  1
            2022.07  3  4  1  2
            2022.08  4  1  2  3
            """


    Scenario: Create weekly chores when there are more tenants than chore types
        Given there are 5 tenants
        And there are 3 chore types
        When I create the weekly chores for the following weeks using the API
            | week_id |
            | 2022.01 |
            | 2022.02 |
            | 2022.03 |
            | 2022.04 |
            | 2022.05 |
            | 2022.06 |
            | 2022.07 |
            | 2022.08 |
        Then I list the weekly chores using the API
        And the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore-list"
        And the response contains the following weekly chores
            """
            type     A  B  C

            2022.01  1  2  3
            2022.02  2  3  4
            2022.03  3  4  5
            2022.04  4  5  1
            2022.05  5  1  2
            2022.06  1  2  3
            2022.07  2  3  4
            2022.08  3  4  5
            """


    Scenario: Create weekly chores when there are more chore types than tenants
        Given there are 3 tenants
        And there are 5 chore types
        When I create the weekly chores for the following weeks using the API
            | week_id |
            | 2022.01 |
            | 2022.02 |
            | 2022.03 |
            | 2022.04 |
            | 2022.05 |
            | 2022.06 |
            | 2022.07 |
            | 2022.08 |
        And I list the weekly chores using the API
        And the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore-list"
        And the response contains the following weekly chores
            """
            type     A  B  C  D  E

            2022.01  1  2  3  1  2
            2022.02  2  3  1  2  3
            2022.03  3  1  2  3  1
            2022.04  1  2  3  1  2
            2022.05  2  3  1  2  3
            2022.06  3  1  2  3  1
            2022.07  1  2  3  1  2
            2022.08  2  3  1  2  3
            """


    Scenario: Return error when creating duplicate weekly chores
        Given there is 1 tenant
        And there is 1 chore type
        And I create the weekly chores for the week "2022.01" using the API
        And the response status code is "200"
        When I create the weekly chores for the week "2022.01" using the API
        Then the response status code is "409"
        And the error message contains "Weekly chores for week .+ already exist"


    Scenario Outline: Return error when creating weekly chores for invalid week
        When I create the weekly chores for the week "<week_id>" using the API
        Then the response status code is "400"
        And the error message contains "Invalid week ID: .+"

        Examples: week_id = <week_id>
            | user         |
            | invalid-week |
            | 2022-03      |
            | 2022.3       |
            | 2022.00      |
            | 2022.55      |
            | whatever     |


    Scenario: Return error when creating weekly chores but there are no tenants
        Given there is 1 chore type
        When I create the weekly chores for the week "2022.01" using the API
        Then the response status code is "400"
        And the error message is "Can't create weekly chores, no tenants registered"


    Scenario: Return error when creating weekly chores but there are no chore types
        Given there is 1 tenant
        When I create the weekly chores for the week "2022.01" using the API
        Then the response status code is "400"
        And the error message is "Can't create weekly chores, no chore types registered"


    Scenario: Return error when deleting an unknown weekly chore
        When I delete the weekly chores for the week "2022.01" using the API
        Then the response status code is "404"
        And the error message is "No weekly chores found for week 2022.01"


    Scenario Outline: Return error when deleting weekly chores for invalid week
        When I delete the weekly chores for the week "<week_id>" using the API
        Then the response status code is "400"
        And the error message is "Invalid week ID: <week_id>"

        Examples: week_id = <week_id>
            | user         |
            | invalid-week |
            | 2022-03      |
            | 2022.3       |
            | 2022.00      |
            | 2022.55      |
            | whatever     |


    Scenario: Get weekly chores by weekId
        Given there is 1 tenant
        And there is 1 chore type
        And I create the weekly chores for the week "2022.01" using the API
        When I get the weekly chores for the week "2022.01" using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore"
        And the response contains the following weekly chores
            """
            type     A

            2022.01  1
            """


    Scenario Outline: Return error when trying to get weekly chores by an invalid weekId
        When I get the weekly chores for the week "<week_id>" using the API
        Then the response status code is "400"
        And the error message contains "Invalid week ID: <week_id>"

        Examples: week_id = <week_id>
            | user         |
            | invalid-week |
            | 2022-03      |
            | 2022.3       |
            | 2022.00      |
            | 2022.55      |
            | whatever     |
