@api.tickets
@listTickets
@sanity
Feature: Tickets API - listTickets

    As a tenant or admin
    I want to list the tickets

    @authorization
    Scenario: Validate response for guest user
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Tenant access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there is 1 tenant
        And I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for admin user
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"


    Scenario: List tickets happy path
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "ticket-list"
        And the Api response contains the expected data


    Scenario: List tickets no tenants
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "ticket-list"
        And the Api response contains the expected data
            """
            []
            """
