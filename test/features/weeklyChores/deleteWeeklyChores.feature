@api.weekly-chores
@deleteWeeklyChores
Feature: Weekly Chores API - deleteWeeklyChores

    As an admin
    I want to delete a weekly chore


    @authorization
    Scenario: Validate response for guest user
        Given the field "weekId" with value "2022.01"
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there is 1 tenant
        And the field "weekId" with value "2022.01"
        And I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Admin access required"


    @authorization
    Scenario: Validate response for admin user
        Given there are 1 tenants, 1 chore types and weekly chores for the week "2022.01"
        And the field "weekId" with value "2022.01"
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "204"


    Scenario: Delete a weekly chore
        Given there are 1 tenants, 1 chore types and weekly chores for the week "2022.01"
        And I use the admin token
        And the field "weekId" with string value "2022.01"
        When I send a request to the Api
        Then the response status code is "204"
        And The Api response is empty
        And the database contains the following weekly chores


    Scenario: Validate error when deleting an unknown weekly chore
        Given I use the admin token
        And the field "weekId" with string value "2022.01"
        When I send a request to the Api
        Then the response status code is "404"
        And the error message is "No weekly chores found for week 2022.01"


    Scenario Outline: Validate error when deleting weekly chores for invalid week
        Given I use the admin token
        And the field "weekId" with string value "<invalid_week_id>"
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
