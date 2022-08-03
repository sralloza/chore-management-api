@api.tenants
@completeTask
Feature: Weekly Chores API - completeTask

    As a tenant or admin
    I want to complete a task

    @authorization
    Scenario: Validate response for guest user
        Given the fields
            | field     | value   |
            | weekId    | 2022.01 |
            | choreType | A       |
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Tenant access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there are 1 tenant, 1 chore type and weekly chores for the week "2022.01"
        And the fields
            | field     | value   |
            | weekId    | 2022.01 |
            | choreType | A       |
        And I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "204"


    @authorization
    Scenario: Validate response for admin user
        Given there are 1 tenant, 1 chore type and weekly chores for the week "2022.01"
        And the fields
            | field     | value   |
            | weekId    | 2022.01 |
            | choreType | A       |
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "204"


    Scenario Outline: Complete task happy path
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And the fields
            | field     | value   |
            | weekId    | 2022.01 |
            | choreType | A       |
        And I use the token of the tenant with id "<tenant_id>"
        When I send a request to the Api
        Then the response status code is "204"
        And the Api response is empty
        When I send a request to the Api resource "listWeeklyChores"
        Then the response status code is "200"
        And the response attribute ".[0].chores[0].done" is "True"
        And the response attribute ".[0].chores[1].done" is "False"

        Examples: tenant_id = <tenant_id>
            | tenant_id |
            | 1         |
            | admin     |


    Scenario Outline: Complete task assigned to two users
        Given there are 3 tenants
        And there are 3 chore types
        And the tenant "3" skips the week "2030.01"
        When I create the weekly chores for the week "2030.01" using the API
        Then the response status code is "200"
        Given the fields
            | field     | value   |
            | weekId    | 2030.01 |
            | choreType | C       |
        And I use the token of the tenant with id "<tenant_id>"
        When I send a request to the Api
        Then the response status code is "204"
        And the Api response is empty
        When I send a request to the Api resource "listWeeklyChores"
        Then the response status code is "200"
        And the response attribute ".[0].chores[0].done" is "False"
        And the response attribute ".[0].chores[1].done" is "False"
        And the response attribute ".[0].chores[2].done" is "True"

        Examples: tenant_id = <tenant_id>
            | tenant_id |
            | 1         |
            | 2         |


    Scenario: Validate error response when requesting other tenant's data
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And the fields
            | field     | value   |
            | weekId    | 2022.01 |
            | choreType | A       |
        And I use the token of the tenant with id "2"
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Can't complete task assigned to other tenant"


    Scenario: Validate error response when completing a task twice
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And the fields
            | field     | value   |
            | weekId    | 2022.01 |
            | choreType | A       |
        And I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "204"
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Chore already completed"


    Scenario Outline: Validate error invalid weekId
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And the fields
            | field     | value             | as_string |
            | weekId    | <invalid_week_id> | True      |
            | choreType | A                 | False     |
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
