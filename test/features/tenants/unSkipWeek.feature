@api.tenants
@unSkipWeek
@sanity
Feature: Tenants API - unSkipWeek

    As a tenant I want to unskip a week in case I have wrongly skipped it.

    # todo: add endpoint /tenants/me/unskip

    # Note: more detailed scenarios are described in the weeklyChores.create feature
    Scenario: a tenant unskips a single week
        Given there are 3 tenants
        And there are 3 chore types
        And the tenant "2" skips the week "2025.01"
        When I send a request to the Api
        Then the response status code is "204"
        And The Api response is empty
        And I create the weekly chores for the week "2025.01" using the API
        And the database contains the following weekly chores
            | week_id | A | B | C |
            | 2025.01 | 1 | 2 | 3 |


    Scenario: validate error when tenants unskips a non skipped week
        Given there is 1 tenant
        And the fields
            | field    | value   | as_string |
            | tenantId | 1       | false     |
            | weekId   | 2022.01 | true      |
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Tenant with id 1 has not skipped the week 2022.01"


    Scenario Outline: Validate error when tenants unskips an invalid week
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
