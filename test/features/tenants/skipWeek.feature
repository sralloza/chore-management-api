@old
@api.tenants
@skipWeek
Feature: Tenants API - skipWeek

    As an admin or tenant
    I want to skip a week


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
        And the fields
            | field    | value   | as_string |
            | tenantId | 2       | false     |
            | weekId   | 2025.01 | false     |
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "204"


    Scenario Outline: A tenant skips a single week
        Given there are 3 tenants
        And there are 3 chore types
        And the fields
            | field    | value       | as_string |
            | tenantId | <tenant_id> | false     |
            | weekId   | 2025.01     | false     |
        And I use the token of the tenant with id "<real_tenant_id>"
        When I send a request to the Api
        Then the response status code is "204"
        And the Api response is empty
        Given I create the weekly chores for the week "2025.01" using the API
        Then the database contains the following weekly chores
            | week_id | A | B   | C |
            | 2025.01 | 1 | 1,3 | 3 |

        Examples: tenant_id = <tenant_id> | real_tenant_id = <real_tenant_id>
            | tenant_id | real_tenant_id |
            | 2         | 2              |
            | me        | 2              |


    Scenario Outline: Validate multiweek syntax support
        Given there are 3 tenants
        And there are 3 chore types
        And the fields
            | field    | value     | as_string |
            | tenantId | 2         | false     |
            | weekId   | <week_id> | true      |
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "204"
        And the Api response is empty
        Given I create the weekly chores for the week "<real_week_id>" using the API
        And the database contains the following weekly chores
            | week_id        | A | B   | C |
            | <real_week_id> | 1 | 1,3 | 3 |

        Examples: week_id = <week_id> | real_week_id = <real_week_id>
            | week_id | real_week_id          |
            | next    | [NOW(%Y.%W) + 7 DAYS] |


    Scenario Outline: A tenant skips the next week
        Given there are 3 tenants
        And there are 3 chore types
        And the fields
            | field    | value                 | as_string |
            | tenantId | <tenant_id>           | false     |
            | weekId   | [NOW(%Y.%W) + 7 DAYS] | true      |
        And I use the token of the tenant with id "<real_tenant_id>"
        When I send a request to the Api
        Then the response status code is "204"
        And the Api response is empty
        Given I create the weekly chores for the week "[NOW(%Y.%W) + 7 DAYS]" using the API
        And the database contains the following weekly chores
            | week_id               | A | B   | C |
            | [NOW(%Y.%W) + 7 DAYS] | 1 | 1,3 | 3 |

        Examples: tenant_id = <tenant_id> | real_tenant_id = <real_tenant_id>
            | tenant_id | real_tenant_id |
            | 2         | 2              |
            | me        | 2              |


    Scenario: Validate error response when using keyword me with the admin token
        Given there is 1 tenant
        And I use the admin API key
        And the fields
            | field    | value   | as_string |
            | tenantId | me      | false     |
            | weekId   | 2025.01 | false     |
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Cannot use keyword me with an admin token"


    Scenario: Validate error response when requesting other tenant's data
        Given there are 2 tenants
        And I use the token of the tenant with id "1"
        And the fields
            | field    | value   | as_string |
            | tenantId | 2       | false     |
            | weekId   | 2025.01 | false     |
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "You don't have permission to access other tenant's data"


    Scenario Outline: Validate error response when tenants skips an invalid week
        Given there is 1 tenant
        And the fields
            | field    | value             | as_string |
            | tenantId | 1                 | false     |
            | weekId   | <invalid_week_id> | true      |
        And I use the admin API key
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


    Scenario: Validate error response when tenant skips a really past week
        Given there is 1 tenant
        And the fields
            | field    | value   | as_string |
            | tenantId | 1       | false     |
            | weekId   | 2022.01 | true      |
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Cannot skip a week in the past"


    Scenario: Validate error response when tenant skips last week
        Given there is 1 tenant
        And the fields
            | field    | value                 | as_string |
            | tenantId | 1                     | false     |
            | weekId   | [NOW(%Y.%W) - 7 DAYS] | true      |
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Cannot skip a week in the past"


    Scenario: Validate error response when tenant skips a week in the past
        Given there is 1 tenant
        And the fields
            | field    | value        | as_string |
            | tenantId | 1            | false     |
            | weekId   | [NOW(%Y.%W)] | true      |
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Cannot skip the current week"
