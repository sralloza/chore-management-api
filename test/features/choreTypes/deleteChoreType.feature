@chore-type
@crud.delete
Feature: Chore Types API - deleteChoreType

    As an admin I want to delete a specific chore type.

    # TODO: validate only admin have access (guests and tenants are not allowed)


    Scenario: delete chore type
        Given there is 1 chore type
        When I delete the chore type with id "A" using the API
        Then the response status code is "204"
        And the database contains the following chore types


    Scenario: validate error when deleting a non existing chore type
        When I delete the chore type with id "invalid" using the API
        Then the response status code is "404"
        And the error message is "No chore type found with id invalid"


    Scenario: validate error when deleting a chore type with pending chores
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I create the weekly chores for the week "2022.02" using the API
        When I delete the chore type with id "A" using the API
        Then the response status code is "400"
        And the error message is "Chore type A has 2 pending chores"


    Scenario: validate error when deleting a chore type with non balanced tickets
        Given there are 2 tenants, 2 chore types and weekly chores for the week "2022.01"
        And I transfer a chore using the API
            | tenant_id_from | tenant_id_to | chore_type | week_id |
            | 1              | 2            | A          | 2022.01 |

        When I delete the chore type with id "A" using the API
        Then the response status code is "400"
        And the error message is "Chore type has unbalanced tickets"
