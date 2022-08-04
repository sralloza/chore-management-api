@api.weekly-chores
@listWeeklyChores
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


    Scenario: list weekly chores
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
