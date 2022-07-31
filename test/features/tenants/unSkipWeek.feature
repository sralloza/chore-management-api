@api.tenants
@unSkipWeek
@sanity
Feature: Tenants API - unSkipWeek

    As a tenant I want to unskip a week in case I have wrongly skipped it.

    # todo: add endpoint /tenants/me/unskip

    @authorization
    Scenario: Validate response for guest user
        Given the fields
            | field    | value   | as_string |
            | tenantId | 1       | false     |
            | weekId   | 2025.01 | false     |
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Tenant access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there is 1 tenant
        And the tenant "1" skips the week "2025.01"
        And the fields
            | field    | value   | as_string |
            | tenantId | 1       | false     |
            | weekId   | 2025.01 | false     |
        And I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "204"


    @authorization
    Scenario: Validate response for admin user
        Given there is 1 tenant
        And the tenant "1" skips the week "2025.01"
        And the fields
            | field    | value   | as_string |
            | tenantId | 1       | false     |
            | weekId   | 2025.01 | false     |
        And I use the admin token
        When I send a request to the Api
        Then the response status code is "204"


    Scenario Outline: a tenant unskips a single week
        Given there are 3 tenants
        And there are 3 chore types
        And the tenant "<real_tenant_id>" skips the week "2025.01"
        And the field "tenantId" with value "<tenant_id>"
        And I use the token of the tenant with id "<real_tenant_id>"
        When I send a request to the Api
        Then the response status code is "204"
        And The Api response is empty
        And I create the weekly chores for the week "2025.01" using the API
        And the database contains the following weekly chores
            | week_id | A | B | C |
            | 2025.01 | 1 | 2 | 3 |

        Examples:
            | tenant_id | real_tenant_id |
            | 2         | 2              |
            | me        | 2              |


    Scenario: Validate error response when using keyword me with the admin token
        Given there is 1 tenant
        And I use the admin token
        And the fields
            | field    | value   | as_string |
            | tenantId | me      | false     |
            | weekId   | 2022.01 | false     |
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Cannot use keyword me with an admin token"


    Scenario: Validate error response when requesting other tenant's data
        Given there are 2 tenants
        And I use the token of the tenant with id "1"
        And the fields
            | field    | value   | as_string |
            | tenantId | 2       | false     |
            | weekId   | 2022.01 | false     |
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "You don't have permission to access other tenant's data"

    Scenario: validate error when tenants unskips a non skipped week
        Given there is 1 tenant
        And the fields
            | field    | value   | as_string |
            | tenantId | 1       | false     |
            | weekId   | 2022.01 | true      |
        And I use the token of the tenant with id "1"
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Tenant with id 1 has not skipped the week 2022.01"


    Scenario Outline: Validate error when tenants unskips an invalid week
        Given there is 1 tenant
        And the fields
            | field    | value             | as_string |
            | tenantId | 1                 | false     |
            | weekId   | <invalid_week_id> | true      |
        And I use the token of the tenant with id "1"
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
