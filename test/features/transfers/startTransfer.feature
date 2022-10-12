@api.transfers
@startTransfer
@sanity
Feature: Transfers API - startTransfer

    As a tenant or admin
    I want to transfer a chore to another tenant


    @authorization
    Scenario: Validate response for guest user
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | 1           |
            | tenant_id_to   | 2           |
            | chore_type     | A           |
            | week_id        | 2022.01     |
        Then the response status code is "403"
        And the error message is "Tenant access required"


    @authorization
    Scenario: Validate response for tenant user
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I use the token of the tenant with id "1"
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | 1           |
            | tenant_id_to   | 2           |
            | chore_type     | A           |
            | week_id        | 2022.01     |
        Then the response status code is "200"


    @authorization
    Scenario: Validate response for admin user
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I use the token of the tenant with id "1"
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | 1           |
            | tenant_id_to   | 2           |
            | chore_type     | A           |
            | week_id        | 2022.01     |
        Then the response status code is "200"


    Scenario: Validate error response when using keyword me with the admin token
        Given there is 1 tenant
        And I use the admin API key
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | me          |
            | tenant_id_to   | 2           |
            | chore_type     | A           |
            | week_id        | 2022.01     |
        Then the response status code is "400"
        And the error message is "Cannot use keyword me with an admin token"


    Scenario: Validate error response when requesting other tenant's data
        Given there are 2 tenants
        And I use the token of the tenant with id "2"
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | 1           |
            | tenant_id_to   | 2           |
            | chore_type     | A           |
            | week_id        | 2022.01     |
        Then the response status code is "403"
        And the error message is "You don't have permission to access other tenant's data"


    Scenario Outline: Start chore transfer happy path
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And I use the token of the tenant with id "<real_tenant_id>"
        When I send a request to the Api with body params
            | param_name     | param_value | as_string |
            | tenant_id_from | <tenant_id> | false     |
            | tenant_id_to   | 2           | false     |
            | chore_type     | A           | false     |
            | week_id        | 2022.01     | true      |
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And the database contains the following transfers
            | tenant_id_from   | tenant_id_to | chore_type | week_id | completed | accepted |
            | <real_tenant_id> | 2            | A          | 2022.01 | False     | None     |
        And the database contains the following weekly chores
            | week_id | A                | B | C |
            | 2022.01 | <real_tenant_id> | 2 | 3 |
        And the database contains the following tickets
            | tenant  | A | B | C |
            | tenant1 | 0 | 0 | 0 |
            | tenant2 | 0 | 0 | 0 |
            | tenant3 | 0 | 0 | 0 |

        Examples: tenant_id = <tenant_id> | real_tenant_id = <real_tenant_id>
            | tenant_id | real_tenant_id |
            | me        | 1              |
            | 1         | 1              |


    Scenario: Start multiple chore transfers
        Given there are 5 tenants
        And there are 5 chore types
        And I create the weekly chores for the week "2022.01" using the API
        And I use the token of the tenant with id "1"
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | 1           |
            | tenant_id_to   | 2           |
            | chore_type     | A           |
            | week_id        | 2022.01     |
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And I use the token of the tenant with id "3"
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | 3           |
            | tenant_id_to   | 1           |
            | chore_type     | C           |
            | week_id        | 2022.01     |
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And I use the token of the tenant with id "5"
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | 5           |
            | tenant_id_to   | 4           |
            | chore_type     | E           |
            | week_id        | 2022.01     |
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And the database contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 2            | A          | 2022.01 | False     | None     |
            | 3              | 1            | C          | 2022.01 | False     | None     |
            | 5              | 4            | E          | 2022.01 | False     | None     |
        And the database contains the following weekly chores
            | week_id | A | B | C | D | E |
            | 2022.01 | 1 | 2 | 3 | 4 | 5 |
        And the database contains the following tickets
            | tenant  | A | B | C | D | E |
            | tenant1 | 0 | 0 | 0 | 0 | 0 |
            | tenant2 | 0 | 0 | 0 | 0 | 0 |
            | tenant3 | 0 | 0 | 0 | 0 | 0 |
            | tenant4 | 0 | 0 | 0 | 0 | 0 |
            | tenant5 | 0 | 0 | 0 | 0 | 0 |


    Scenario: Start chore transfer to user2 after user1 has rejected it.
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And I use the token of the tenant with id "1"
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | 1           |
            | tenant_id_to   | 2           |
            | chore_type     | A           |
            | week_id        | 2022.01     |
        Then the response status code is "200"
        Given I save the "id" attribute of the response as "transferId"
        And I use the token of the tenant with id "2"
        When I send a request to the Api resource "rejectTransfer"
        Then the response status code is "200"
        Given I use the token of the tenant with id "1"
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | 1           |
            | tenant_id_to   | 3           |
            | chore_type     | A           |
            | week_id        | 2022.01     |
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And the response contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 3            | A          | 2022.01 | False     | None     |
        And the database contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 2            | A          | 2022.01 | True      | False    |
            | 1              | 3            | A          | 2022.01 | False     | None     |


    Scenario: Admin makes a chore transfer
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I use the admin API key
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | 1           |
            | tenant_id_to   | 2           |
            | chore_type     | A           |
            | week_id        | 2022.01     |
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And the database contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 2            | A          | 2022.01 | False     | None     |
        And the database contains the following weekly chores
            | week_id | A | B |
            | 2022.01 | 1 | 2 |
        And the database contains the following tickets
            | tenant  | A | B |
            | tenant1 | 0 | 0 |
            | tenant2 | 0 | 0 |

    @timing
    Scenario: Validate transfer timestamp after transfer is created
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And I use the token of the tenant with id "1"
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | 1           |
            | tenant_id_to   | 2           |
            | chore_type     | A           |
            | week_id        | 2022.01     |
        Then the response status code is "200"
        And the response timestamp attribute is at most "50" ms ago


    Scenario: Validate error response when a tenant tries to transfer a chore to multiple tenants
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And I use the token of the tenant with id "1"
        When I send a request to the Api with body params
            | param_name     | param_value |
            | tenant_id_from | 1           |
            | tenant_id_to   | 2           |
            | chore_type     | A           |
            | week_id        | 2022.01     |
        Then the response status code is "200"
        When I send a request to the Api with body params
            | param_name     | param_value | as_string |
            | tenant_id_from | 1           | false     |
            | tenant_id_to   | 3           | false     |
            | chore_type     | A           | false     |
            | week_id        | 2022.01     | true      |
        Then the response status code is "400"
        And the error message is "Cannot transfer chore to multiple tenants"


    Scenario Outline: Validate error response automatic validations
        Given there is 1 tenant
        And I use the admin API key
        When I send a request to the Api with body params
            | param_name     | param_value      | as_string |
            | tenant_id_from | <tenant_id_from> | false     |
            | tenant_id_to   | <tenant_id_to>   | false     |
            | chore_type     | <chore_type>     | false     |
            | week_id        | <week_id>        | true      |
        Then the response status code is "400"
        And one of messages in the errors array is "<err_msg>"

        Examples: tenant_id_from = <tenant_id_from> | tenant_id_to = <tenant_id_to> | chore_type = <chore_type> | week_id = <week_id> | err_msg = <err_msg>
            | tenant_id_from | tenant_id_to | chore_type | week_id | err_msg                       |
            | [NULL]         | 2            | A          | 2022.01 | tenant_id_from is required    |
            | 1              | [NULL]       | A          | 2022.01 | tenant_id_to is required      |
            | 1              | -1           | A          | 2022.01 | tenant_id_to must be positive |
            | 1              | 0            | A          | 2022.01 | tenant_id_to must be positive |
            | 1              | 2            | [NULL]     | 2022.01 | chore_type is required        |
            | 1              | 2            | [EMPTY]    | 2022.01 | chore_type can't be blank     |
            | 1              | 2            | [B]        | 2022.01 | chore_type can't be blank     |
            | 1              | 2            | A          | [NULL]  | week_id is required           |
            | 1              | 2            | A          | [EMPTY] | week_id can't be blank        |
            | 1              | 2            | A          | [B]     | week_id can't be blank        |


    Scenario Outline: Validate error response manual validations
        And I use the admin API key
        When I send a request to the Api with body params
            | param_name     | param_value      | as_string |
            | tenant_id_from | <tenant_id_from> | false     |
            | tenant_id_to   | 2                | false     |
            | chore_type     | A                | false     |
            | week_id        | <week_id>          | true      |
        Then the response status code is "400"
        And the error message contains "<err_msg>"
        Examples: tenant_id_from = <tenant_id_from> | week_id = <week_id> | err_msg = <err_msg>
            | tenant_id_from | week_id  | err_msg                         |
            | -1             | 2022.01  | tenant_id_from must be positive |
            | 0              | 2022.01  | tenant_id_from must be positive |
            | 1              | 2022-03  | Invalid week ID                 |
            | 1              | 2022.3   | Invalid week ID                 |
            | 1              | 2022.00  | Invalid week ID                 |
            | 1              | 2022.55  | Invalid week ID                 |
            | 1              | 2022023  | Invalid week ID                 |
            | 1              | whatever | Invalid week ID                 |



    Scenario Outline: Validate error response when the tenant_id does not belong to any tenant
        Given there are 3 tenants
        And I use the admin API key
        When I send a request to the Api with body params
            | param_name     | param_value      | as_string |
            | tenant_id_from | <tenant_id_from> | false     |
            | tenant_id_to   | <tenant_id_to>   | false     |
            | chore_type     | A                | false     |
            | week_id        | 2022.01          | true      |
        Then the response status code is "400"
        And the error message is "Tenant with id 9999 does not exist"

        Examples: tenant_id_from = <tenant_id_from> | tenant_id_to = <tenant_id_to>
            | tenant_id_from | tenant_id_to |
            | 9999           | 2            |
            | 1              | 9999         |


    Scenario: Validate error response when the tenant_id_from is the same as the tenant_id_to
        Given I use the admin API key
        When I send a request to the Api with body params
            | param_name     | param_value | as_string |
            | tenant_id_from | 1           | false     |
            | tenant_id_to   | 1           | false     |
            | chore_type     | A           | false     |
            | week_id        | 2022.01     | true      |
        Then the response status code is "400"
        And the error message is "Cannot transfer chore to the same tenant"


    Scenario: Validate error response when a tenant tries to transfer a chore that belongs to another tenant
        Given there are 3 tenants
        And there are 3 chore types
        And I create the weekly chores for the week "2022.01" using the API
        Given I use the token of the tenant with id "1"
        When I send a request to the Api with body params
            | param_name     | param_value | as_string |
            | tenant_id_from | 1           | false     |
            | tenant_id_to   | 2           | false     |
            | chore_type     | C           | false     |
            | week_id        | 2022.01     | true      |
        Then the response status code is "403"
        And the error message is the following
            """
            You cannot transfer chores from other tenants. The chore you are trying to transfer is assigned to tenant3.
            """


    Scenario: Validate error response when a tenant tries to transfer a chore which type does not exist
        Given there are 3 tenants
        And I use the admin API key
        When I send a request to the Api with body params
            | param_name     | param_value | as_string |
            | tenant_id_from | 1           | false     |
            | tenant_id_to   | 2           | false     |
            | chore_type     | X           | false     |
            | week_id        | 2022.01     | true      |
        Then the response status code is "400"
        And the error message is "Chore type with id X does not exist"
