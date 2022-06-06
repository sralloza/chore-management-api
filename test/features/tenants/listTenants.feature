Feature: Tenants API - listTenants

    Scenario: List tenants
        Given there are 5 tenants
        When I list the tenants using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant-list"
        And the response should contain the following tenants
            | username | telegram_id |
            | tenant1  | [INT:1]     |
            | tenant2  | [INT:2]     |
            | tenant3  | [INT:3]     |
            | tenant4  | [INT:4]     |
            | tenant5  | [INT:5]     |
