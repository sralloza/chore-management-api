@api.tenants
@skipWeek
@sanity
Feature: Tenants API - skipWeek

    As a tenant, some weeks I may not be living in the apartment so
    I don't have to clean it.

    # todo: add endpoint /tenants/me/skip

    # Note: more detailed scenarios are described in the weeklyChores.create feature
    Scenario: a tenant skips a single week
        Given there are 3 tenants
        And there are 3 chore types
        And the fields
            | field    | value   | as_string |
            | tenantId | 2       | false     |
            | weekId   | 2025.01 | false     |
        When I send a request to the Api
        Then the response status code is "204"
        And The Api response is empty
        And I create the weekly chores for the week "2025.01" using the API
        And the database contains the following weekly chores
            | week_id | A | B   | C |
            | 2025.01 | 1 | 1,3 | 3 |


    Scenario: a tenant skips the next week
        Given there are 3 tenants
        And there are 3 chore types
        And the fields
            | field    | value                 | as_string |
            | tenantId | 2                     | false     |
            | weekId   | [NOW(%Y.%W) + 7 DAYS] | true      |
        When I send a request to the Api
        Then the response status code is "204"
        And The Api response is empty
        And I create the weekly chores for next week using the API
        And the database contains the following weekly chores
            | week_id               | A | B   | C |
            | [NOW(%Y.%W) + 7 DAYS] | 1 | 1,3 | 3 |


    Scenario Outline: Validate error when tenants skips an invalid week
        Given there is 1 tenant
        And the fields
            | field    | value             | as_string |
            | tenantId | 1                 | false     |
            | weekId   | <invalid_week_id> | true      |
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


    Scenario: validate error when tenant skips a really past week
        Given there is 1 tenant
        And the fields
            | field    | value   | as_string |
            | tenantId | 1       | false     |
            | weekId   | 2022.01 | true      |
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Cannot skip a week in the past"


    Scenario: validate error when tenant skips last week
        Given there is 1 tenant
        And the fields
            | field    | value                 | as_string |
            | tenantId | 1                     | false     |
            | weekId   | [NOW(%Y.%W) - 7 DAYS] | true      |
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Cannot skip a week in the past"


    Scenario: validate error when tenant skips a week in the past
        Given there is 1 tenant
        And the fields
            | field    | value        | as_string |
            | tenantId | 1            | false     |
            | weekId   | [NOW(%Y.%W)] | true      |
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Cannot skip the current week"
