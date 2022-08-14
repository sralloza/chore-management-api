@api.weekly-chores
@listWeeklyChores
@sanity
Feature: Weekly Chores API - listWeeklyChores

    As a tenant or admin
    I want to list all weekly chores

    @authorization
    Scenario: Validate response for guest user
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Tenant access required"


    @authorization
    Scenario: Validate response for tenant user
        Given I use a tenant's token
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for admin user
        Given I use the admin token
        When I send a request to the Api
        Then the response status code is "200"


    Scenario: List weekly chores
        Given there is 1 tenant
        And there is 1 chore type
        And I create the weekly chores for the following weeks using the API
            | week_id |
            | 2022.01 |
            | 2022.02 |
            | 2022.03 |
        And I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore-list"
        And the Api response contains the expected data


    Scenario Outline: List missing weekly chores
        Given there are 2 tenants
        And there are 2 chore types
        And I create the weekly chores for the following weeks using the API
            | week_id |
            | 2022.01 |
            | 2022.02 |
            | 2022.03 |
        And I use the admin token
        And the fields
            | field     | value   |
            | choreType | A       |
            | weekId    | 2022.01 |
        When I send a request to the Api resource "completeTask"
        And the fields
            | field     | value   |
            | choreType | B       |
            | weekId    | 2022.01 |
        When I send a request to the Api resource "completeTask"
        Then the response status code is "204"
        And the fields
            | field     | value   |
            | choreType | A       |
            | weekId    | 2022.02 |
        When I send a request to the Api resource "completeTask"
        Then the response status code is "204"
        Given I use the token of the tenant with id "1"
        And the parameters to filter the request
            | param_name  | param_value    |
            | missingOnly | <missing_only> |
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "weekly-chore-list"
        And the Api response contains the expected data
            """
            <expected_json>
            """

        Examples:
            | missing_only | expected_json                    |
            | [TRUE]       | listWeeklyChoresMissingOnlyTrue  |
            | [FALSE]      | listWeeklyChoresMissingOnlyFalse |
