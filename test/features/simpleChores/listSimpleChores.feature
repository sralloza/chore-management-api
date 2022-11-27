@old
@api.simple-chores
@listSimpleChores
@old
Feature: Simple Chores API - listSimpleChores

    As an admin or tenant
    I want to list the ungrouped chores


    @authorization
    Scenario: Validate response for guest user
        When I send a request to the Api
        Then the response status code is "403"
        And the error message is "Tenant access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there is 1 tenant
        And I use a tenant's token
        When I send a request to the Api
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for admin user
        Given there is 1 tenant
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"


    Scenario: List simple chores when no chores
        Given I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"
        And the Api response contains the expected data
            """
            []
            """


    Scenario: List simple chores when database is not empty
        Given there are 4 tenants, 4 chore types and weekly chores for the week "2030.01"
        And the fields
            | field     | value   |
            | weekId    | 2030.01 |
            | choreType | A       |
        And I use the token of the tenant with id "1"
        When I send a request to the Api resource "completeTask"
        Then the response status code is "204"
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "simple-chore-list"
        And the Api response contains the expected data


    Scenario Outline: Validate filters
        Given there are 4 tenants
        And there are 4 chore types
        And I create the weekly chores for the following weeks using the API
            | week_id |
            | 2030.01 |
            | 2030.02 |
        And the fields
            | field     | value   |
            | weekId    | 2030.01 |
            | choreType | A       |
        And I use the token of the tenant with id "1"
        When I send a request to the Api resource "completeTask"
        Then the response status code is "204"
        Given the parameters to filter the request
            | param_name | param_value  |
            | choreType  | <chore_type> |
            | tenantId   | <tenant_id>  |
            | weekId     | <week_id>    |
            | done       | <done>       |
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema "simple-chore-list"
        And the response contains the simple chores "<result>"

        Examples: chore_type = <chore_type> | tenant_id = <tenant_id> | week_id = <week_id> | done = <done> | result = <result>
            | chore_type | tenant_id | week_id | done    | result          |
            | [NULL]     | [NULL]    | [NULL]  | [NULL]  | 1,2,3,4,5,6,7,8 |
            | A          | [NULL]    | [NULL]  | [NULL]  | 1,5             |
            | [NULL]     | 1         | [NULL]  | [NULL]  | 1,8             |
            | [NULL]     | me        | [NULL]  | [NULL]  | 1,8             |
            | [NULL]     | [NULL]    | 2030.01 | [NULL]  | 1,2,3,4         |
            | [NULL]     | [NULL]    | 2030.02 | [NULL]  | 5,6,7,8         |
            | [NULL]     | [NULL]    | [NULL]  | [TRUE]  | 1               |
            | [NULL]     | [NULL]    | [NULL]  | [FALSE] | 2,3,4,5,6,7,8   |
            | A          | 1         | [NULL]  | [NULL]  | 1               |
            | A          | me        | [NULL]  | [NULL]  | 1               |
            | [NULL]     | [NULL]    | 2030.01 | [TRUE]  | 1               |
            | [NULL]     | [NULL]    | 2030.01 | [FALSE] | 2,3,4           |
            | [NULL]     | [NULL]    | 2030.02 | [TRUE]  | [EMPTY]         |
            | [NULL]     | 1         | [NULL]  | [FALSE] | 8               |
            | [NULL]     | me        | [NULL]  | [FALSE] | 8               |
            | [NULL]     | 1         | [NULL]  | [TRUE]  | 1               |
            | [NULL]     | me        | [NULL]  | [TRUE]  | 1               |
            | B          | [NULL]    | [NULL]  | [FALSE] | 2,6             |

    Scenario: Validate error response when using keyword me with the admin token
        Given there is 1 tenant
        And I use the admin API key
        Given the parameters to filter the request
            | param_name | param_value |
            | tenantId   | me          |
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Cannot use keyword me with an admin token"


    Scenario Outline: Validate error response when filtering by an invalid weekId
        Given the parameters to filter the request
            | param_name | param_value |
            | weekId     | <week_id>   |
        When I send a request to the Api
        Then the response status code is "400"
        And the error message contains "Invalid week ID: <week_id>"

        Examples: week_id = <week_id>
            | invalid_week_id |
            | invalid-week    |
            | 2022-03         |
            | 2022.3          |
            | 2022.00         |
            | 2022.55         |
            | 2022023         |
            | whatever        |
