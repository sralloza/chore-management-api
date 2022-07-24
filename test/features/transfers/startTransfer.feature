@transfers
@transfers.start
Feature: Transfers API - startTransfer

    As a tenant I want to transfer a chore to another tenant.

    # todo: only admin and tenants can access this endpoint, guests can't.
    # todo: tenants can't transfer chores in name of other tenants (tenant_id_from will always  be the tenant itself).
    # todo: tenants can use the keyword "me" to refer to themselves.

    Scenario: Start chore transfer happy path
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And the database contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 2            | A          | 2022.01 | False     | None     |
        And the database contains the following weekly chores
            | week_id | A | B | C |
            | 2022.01 | 1 | 2 | 3 |
        And the database contains the following tickets
            | tenant  | A | B | C |
            | tenant1 | 0 | 0 | 0 |
            | tenant2 | 0 | 0 | 0 |
            | tenant3 | 0 | 0 | 0 |


    Scenario: Start multiple chore transfers
        Given there are 5 tenants
        And there are 5 chore types
        And I create the weekly chores for the week "2022.01" using the API
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 3              | 1            | C          | 2022.01 |
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 5              | 4            | E          | 2022.01 |
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
        And a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        And the response status code is "200"
        And I save the "id" attribute of the response as "transfer_id"
        And a tenant rejects the chore transfer with id saved as "transfer_id" using the API
        And the response status code is "200"
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 3            | A          | 2022.01 |
        Then the response status code is "200"
        And the response body is validated against the json-schema "transfer"
        And the response contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 3            | A          | 2022.01 | False     | None     |
        And the database contains the following transfers
            | tenant_id_from | tenant_id_to | chore_type | week_id | completed | accepted |
            | 1              | 2            | A          | 2022.01 | True      | False    |
            | 1              | 3            | A          | 2022.01 | False     | None     |


    @timing
    Scenario: Validate transfer timestamp after transfer is created
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        Then the response status code is "200"
        And the response timestamp attribute is at most "20" ms ago


    Scenario: Validate error when a tenant tries to transfer a chore to multiple tenants
        Given there are 3 tenants, 3 chore types and weekly chores for the week "2022.01"
        And a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 3            | A          | 2022.01 |
        Then the response status code is "400"
        And the error message is "Cannot transfer chore to multiple tenants"


    Scenario Outline: Validate error when tenant_id_from is invalid
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | <tenant_id>    | 2            | A          | 2022.01 |
        Then the response status code is "400"
        And one of messages in the errors array is "<err_msg>"

        Examples: tenant_id = <tenant_id> | err_msg = <err_msg>
            | tenant_id | err_msg                         |
            | [NULL]    | tenant_id_from is required      |
            | -1        | tenant_id_from must be positive |
            | 0         | tenant_id_from must be positive |


    Scenario Outline: Validate error when tenant_id_to is invalid
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | <tenant_id>  | A          | 2022.01 |
        Then the response status code is "400"
        And one of messages in the errors array is "<err_msg>"

        Examples: tenant_id = <tenant_id> | err_msg = <err_msg>
            | tenant_id | err_msg                       |
            | [NULL]    | tenant_id_to is required      |
            | -1        | tenant_id_to must be positive |
            | 0         | tenant_id_to must be positive |


    Scenario Outline: Validate error when chore_type is invalid
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type   | week_id |
            | 1              | 2            | <chore_type> | 2022.01 |
        Then the response status code is "400"
        And one of messages in the errors array is "<err_msg>"

        Examples: chore_type = <chore_type> | err_msg = <err_msg>
            | chore_type | err_msg                   |
            | [NULL]     | chore_type is required    |
            | [EMPTY]    | chore_type can't be blank |
            | [B]        | chore_type can't be blank |


    Scenario Outline: Validate error when week_id is invalid
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id   |
            | 1              | 2            | A          | <week_id> |
        Then the response status code is "400"
        And one of messages in the errors array is "<err_msg>"

        Examples: week_id = <week_id> | err_msg = <err_msg>
            | week_id | err_msg                |
            | [NULL]  | week_id is required    |
            | [EMPTY] | week_id can't be blank |
            | [B]     | week_id can't be blank |


    Scenario Outline: Validate error when week_id's format is invalid
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id   |
            | 1              | 2            | A          | <week_id> |
        Then the response status code is "400"
        And the error message is "Invalid week ID: <week_id>"

        Examples: week_id = <week_id>
            | week_id  |
            | 2022-03  |
            | 2022.3   |
            | 2022.00  |
            | 2022.55  |
            | 2022023  |
            | whatever |


    Scenario: Validate error when the tenant_id_from does not belong to any tenant
        Given there are 3 tenants
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 9999           | 2            | A          | 2022.01 |
        Then the response status code is "400"
        And the error message is "Tenant with id 9999 does not exist"


    Scenario: Validate error when the tenant_id_to does not belong to any tenant
        Given there are 3 tenants
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 9999         | A          | 2022.01 |
        Then the response status code is "400"
        And the error message is "Tenant with id 9999 does not exist"


    Scenario: Validate error when the tenant_id_from is the same as the tenant_id_to
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 1            | A          | 2022.01 |
        Then the response status code is "400"
        And the error message is "Cannot transfer chore to the same tenant"


    Scenario: Validate error when a tenant tries to transfer a chore that belongs to another tenant
        Given there are 3 tenants
        And there are 3 chore types
        And I create the weekly chores for the week "2022.01" using the API
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | C          | 2022.01 |
        Then the response status code is "403"
        And the error message is the following
            """
            You cannot transfer chores from other tenants. The chore you are trying to transfer is assigned to tenant3.
            """


    Scenario: Validate error when a tenant tries to transfer a chore which type does not exist
        Given there are 3 tenants
        When a tenant starts a chore transfer to other tenant using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | X          | 2022.01 |
        Then the response status code is "400"
        And the error message is "Chore type with id X does not exist"
