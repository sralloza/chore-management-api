@api.weekly-chores
@getWeeklyChores
Feature: Weekly Chores API - getWeeklyChores

    As an admin or tenant
    I want to get the detils of the weekly chores given a specific week


    @authorization
    Scenario: Validate response for guest user
        Given the field "weekId" with string value "2022.01"
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Tenant access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there are 1 tenant, 1 chore type and weekly chores for the week "2022.01"
        And the field "weekId" with string value "2022.01"
        And I use a tenant's token
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for admin user
        Given there are 1 tenant, 1 chore type and weekly chores for the week "2022.01"
        And the field "weekId" with string value "2022.01"
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"


    Scenario Outline: Get weekly chores by weekId
        Given there are 1 tenant, 1 chore type and weekly chores for the week "<real_week_id>"
        And I use the token of the tenant with id "1"
        And the field "weekId" with string value "<week_id>"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore"
        And the response contains the following weekly chores
            | week_id        | A |
            | <real_week_id> | 1 |

        Examples: week_id = <week_id> | real_week_id = <real_week_id>
            | week_id | real_week_id          |
            | next    | [NOW(%Y.%W) + 7 DAYS] |
            | current | [NOW(%Y.%W)]          |
            | last    | [NOW(%Y.%W) - 7 DAYS] |


    Scenario: Validate error response when weekly chores not found
        Given I use the admin API key
        And the field "weekId" with value "2022.01"
        When I send a request to the Api
        Then the response status code is "404"
        And the error message is "No weekly chores found for week 2022.01"


    Scenario Outline: Validate error response when trying to get weekly chores by an invalid weekId
        Given the field "weekId" with string value "<invalid_week_id>"
        When I send a request to the Api
        Then the response status code is "400"
        And the error message contains "Invalid week ID: <invalid_week_id>"

        Examples: invalid_week_id = <invalid_week_id>
            | invalid_week_id |
            | invalid-week    |
            | 2022-03         |
            | 2022.3          |
            | 2022.00         |
            | 2022.55         |
            | 2022023         |
            | whatever        |
