@tenants
@crud.list
Feature: Tenants API - listTenants

    Scenario: List tenants
        Given there are 5 tenants
        When I list the tenants using the API
        Then the response status code is "200"
        And the response body is validated against the json-schema "tenant-list"
        And the response contains the following tenants
            | username | tenant_id |
            | tenant1  | 1         |
            | tenant2  | 2         |
            | tenant3  | 3         |
            | tenant4  | 4         |
            | tenant5  | 5         |
