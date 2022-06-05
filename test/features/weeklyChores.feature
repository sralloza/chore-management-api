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
            | 2022.15 |
            | 2022.16 |
            | 2022.17 |
            | 2022.18 |
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
            2022.15  1  2  3  4
            2022.16  2  3  4  1
            2022.17  3  4  1  2
            2022.18  4  1  2  3
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
            | 2022.15 |
            | 2022.16 |
            | 2022.17 |
            | 2022.18 |
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
            2022.15  5  1  2
            2022.16  1  2  3
            2022.17  2  3  4
            2022.18  3  4  5
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
            | 2022.15 |
            | 2022.16 |
            | 2022.17 |
            | 2022.18 |
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
            2022.15  2  3  1  2  3
            2022.16  3  1  2  3  1
            2022.17  1  2  3  1  2
            2022.18  2  3  1  2  3
            """


    Scenario: Create weekly chores when a tenant skips a week
        Given there are 4 tenants
        And there are 4 chore types
        And the tenant 2 skips the week "2022.15" using the API
        And I create the weekly chores for the following weeks using the API
            | week_id |
            | 2022.01 |
            | 2022.02 |
            | 2022.03 |
            | 2022.04 |
            | 2022.15 |
            | 2022.16 |
            | 2022.17 |
            | 2022.18 |
        And I list the weekly chores using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore-list"
        And the response contains the following weekly chores
            """
            type     A      B  C  D

            2022.01  1      2  3  4
            2022.02  2      3  4  1
            2022.03  3      4  1  2
            2022.04  4      1  2  3
            2022.15  1  1,3,4  3  4
            2022.16  2      3  4  1
            2022.17  3      4  1  2
            2022.18  4      1  2  3
            """


    Scenario: Create weekly chores when two tenants skips a couple of weeks
        Given there are 4 tenants
        And there are 4 chore types
        And the tenant 2 skips the week "2022.15" using the API
        And the tenant 3 skips the week "2022.15" using the API
        And the tenant 3 skips the week "2022.16" using the API
        And I create the weekly chores for the following weeks using the API
            | week_id |
            | 2022.01 |
            | 2022.02 |
            | 2022.03 |
            | 2022.04 |
            | 2022.15 |
            | 2022.16 |
            | 2022.17 |
            | 2022.18 |
        And I list the weekly chores using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore-list"
        And the response contains the following weekly chores
            """
            type     A      B    C  D

            2022.01  1      2    3  4
            2022.02  2      3    4  1
            2022.03  3      4    1  2
            2022.04  4      1    2  3
            2022.15  1    1,4  1,4  4
            2022.16  2  1,2,4    4  1
            2022.17  3      4    1  2
            2022.18  4      1    2  3
            """


    Scenario: Create weekly chores when all tenants but one skip a week
        Given there are 4 tenants
        And there are 4 chore types
        And the tenant 1 skips the week "2022.15" using the API
        And the tenant 2 skips the week "2022.15" using the API
        And the tenant 4 skips the week "2022.15" using the API
        And I create the weekly chores for the following weeks using the API
            | week_id |
            | 2022.01 |
            | 2022.02 |
            | 2022.03 |
            | 2022.04 |
            | 2022.15 |
            | 2022.16 |
            | 2022.17 |
            | 2022.18 |
        And I list the weekly chores using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore-list"
        And the response contains the following weekly chores
            """
            type     A  B  C  D

            2022.01  1  2  3  4
            2022.02  2  3  4  1
            2022.03  3  4  1  2
            2022.04  4  1  2  3
            2022.15  3  3  3  3
            2022.16  1  2  3  4
            2022.17  2  3  4  1
            2022.18  3  4  1  2
            """


    Scenario: Return error when a tenant skips twice the same week
        Given there is 1 tenant
        And the tenant 1 skips the week "2022.01" using the API
        And the tenant 1 skips the week "2022.01" using the API
        Then the response status code is "400"
        And the error message is "Tenant tenant1 has already skipped the week 2022.01"


    Scenario Outline: Return error when tenants skips an invalid week
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


    Scenario: Return error when creating duplicate weekly chores
        Given there is 1 tenant
        And there is 1 chore type
        And I create the weekly chores for the week "2022.01" using the API
        And the response status code is "200"
        When I create the weekly chores for the week "2022.01" using the API
        Then the response status code is "409"
        And the error message contains "Weekly chores for week .+ already exist"


    Scenario Outline: Return error when creating weekly chores for invalid week
        When I create the weekly chores for the week "<invalid_week_id>" using the API
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

    Scenario Outline: Return error when creating weekly chores for an old week
        Given there is 1 tenant
        And there is 1 chore type
        And I create the weekly chores for the week "2022.10" using the API
        When I create the weekly chores for the week "<old_week_id>" using the API
        Then the response status code is "400"
        And the error message is "Invalid week ID (too old): <old_week_id>"

        Examples: Old week IDs
            | old_week_id |
            | 2022.09     |
            | 2022.04     |
            | 2021.04     |
            | 2020.44     |


    Scenario: Return error when creating weekly chores after tenants have changed
        Given there are 3 tenants
        And there are 3 chore types
        And I create the weekly chores for the week "2022.01" using the API
        And I create a tenant with name "John" and id 111 using the API
        When I create the weekly chores for the week "2022.02" using the API
        Then the response status code is "400"
        And the error message is the following
            """
            Tenants have changed since weekly chore creation. Use force parameter to restart the weekly chores creation.
            """


    Scenario: Create weekly tasks if a tenant is created and removed
        Given there are 3 tenants
        And there are 3 chore types
        And I create the weekly chores for the week "2022.01" using the API
        And I create a tenant with name "John" and id 111 using the API
        And I remove the tenant with id 111 using the API
        When I create the weekly chores for the week "2022.02" using the API
        Then the response status code is "200"
        And I list the weekly chores using the API
        And the response status code is "200"
        And the response contains the following weekly chores
            """
            type     A  B  C

            2022.01  1  2  3
            2022.02  2  3  1
            """


    Scenario: Restart weekly tasks creation if new tenant is registered using weekID endpoint
        Given there are 3 tenants
        And there are 5 chore types
        And I create the weekly chores for the following weeks using the API
            | week_id |
            | 2022.01 |
            | 2022.02 |
        And I create a tenant with name "tenant4" and id 4 using the API
        When I create the weekly chores for the week "2022.03" with force=true using the API
        Then the response status code is "200"
        And I list the weekly chores using the API
        And the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore-list"
        And the response contains the following weekly chores
            """
            type     A  B  C  D  E

            2022.01  1  2  3  1  2
            2022.02  2  3  1  2  3
            2022.03  1  2  3  4  1
            """


    Scenario: Restart weekly tasks creation if new tenant is registered using next week endpoint
        Given there are 3 tenants
        And there are 5 chore types
        And I create the weekly chores for the following weeks using the API
            | week_id |
            | 2022.01 |
            | 2022.02 |
        And I create a tenant with name "tenant4" and id 4 using the API
        When I create the weekly chores for next week with force=true using the API
        Then the response status code is "200"
        And I list the weekly chores using the API
        And the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore-list"
        And the response contains the following weekly chores
            """
            type     A  B  C  D  E

            2022.01  1  2  3  1  2
            2022.02  2  3  1  2  3
            {next}  1  2  3  4  1
            """


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
        When I delete the weekly chores for the week "<invalid_week_id>" using the API
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
