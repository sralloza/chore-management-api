Feature: Transfer Chores API - transferChore
    Scenario: Simple chore transfer
        Given there are 2 tenants
        And there are 2 chore types
        And I create the weekly chores for the week "2022.01" using the API
        When a tenant transfers a chore to other tenant using the API
            | tenant_id_origin | tenant_id_dest | chore_type | week_id |
            | 1                | 2              | A          | 2022.01 |
        Then the response status code is "204"
        And the database contains the following weekly chores
            | week_id | A | B |
            | 2022.01 | 2 | 2 |
        And the database contains the following tickets
            | tenant  | A  | B |
            | tenant1 | -1 | 0 |
            | tenant2 | 1  | 0 |
