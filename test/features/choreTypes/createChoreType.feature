@api.chore-types
@createChoreType
Feature: Chore Types API - createChoreType

    As an admin I want to register chore types.

    # TODO: validate only admin can register chore types (guests and tenants are not allowed).


    Scenario: Create a chore type without tenants
        When I send a request to the Api with body params
            | param_name  | param_value              |
            | id          | chore-type-1             |
            | description | description-chore-type-1 |
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type"
        When I send a request to the Api resource "listChoreTypes"
        Then the response status code is "200"
        And the Api response contains the expected data
            """
            [
                {
                    "id": "chore-type-1",
                    "description": "description-chore-type-1"
                }
            ]
            """
        And the database contains the following tickets


    Scenario: Validate that tickets are created after the chore type
        Given there are 3 tenants
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | id          | new-chore             |
            | description | new-chore-description |
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type"
        When I send a request to the Api resource "listChoreTypes"
        Then the response status code is "200"
        And the Api response contains the expected data
            """
            [
                {
                    "id": "new-chore",
                    "description": "new-chore-description"
                }
            ]
            """
        And the database contains the following tickets
            | tenant  | new-chore |
            | tenant1 | 0         |
            | tenant2 | 0         |
            | tenant3 | 0         |


    Scenario: Validate error creating a chore type with a null id
        When I send a request to the Api with body params
            | param_name  | param_value              |
            | id          | [NULL]                   |
            | description | description-chore-type-1 |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.id cannot be null
            """


    Scenario: Validate error creating a chore type with an empty id
        When I send a request to the Api with body params
            | param_name  | param_value              |
            | id          | [EMPTY]                  |
            | description | description-chore-type-1 |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.id cannot be blank
            """


    Scenario: Validate error creating a chore type with a blank id
        When I send a request to the Api with body params
            | param_name  | param_value              |
            | id          | [B]                      |
            | description | description-chore-type-1 |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.id cannot be blank
            """


    Scenario: create a chore type with the largest id possible
        When I send a request to the Api with body params
            | param_name  | param_value              |
            | id          | [STRING_WITH_LENGTH_25]  |
            | description | description-chore-type-1 |
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type"
        When I send a request to the Api resource "listChoreTypes"
        Then the response status code is "200"
        And the Api response contains the expected data
            """
            [
                {
                    "id": "[STRING_WITH_LENGTH_25]",
                    "description": "description-chore-type-1"
                }
            ]
            """


    Scenario: Validate error creating a chore type with an id too long
        When I send a request to the Api with body params
            | param_name  | param_value              |
            | id          | [STRING_WITH_LENGTH_26]  |
            | description | description-chore-type-1 |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.id must have between 1 and 25 characters
            """


    Scenario: Validate error creating a chore type with a null description
        When I send a request to the Api with body params
            | param_name  | param_value  |
            | id          | chore-type-1 |
            | description | [NULL]       |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.description cannot be null
            """


    Scenario: Validate error creating a chore type with an empty description
        When I send a request to the Api with body params
            | param_name  | param_value  |
            | id          | chore-type-1 |
            | description | [EMPTY]      |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.description cannot be blank
            """


    Scenario: Validate error creating a choreType with a blank description
        When I send a request to the Api with body params
            | param_name  | param_value  |
            | id          | chore-type-1 |
            | description | [B]          |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.description cannot be blank
            """


    Scenario: create a choreType with the largest description possible
        When I send a request to the Api with body params
            | param_name  | param_value              |
            | id          | chore-type-1             |
            | description | [STRING_WITH_LENGTH_255] |
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type"
        When I send a request to the Api resource "listChoreTypes"
        Then the response status code is "200"
        And the Api response contains the expected data
            """
            [
                {
                    "id": "chore-type-1",
                    "description": "[STRING_WITH_LENGTH_255]"
                }
            ]
            """


    Scenario: Validate error creating a choreType with a description too long
        When I send a request to the Api with body params
            | param_name  | param_value              |
            | id          | chore-type-1             |
            | description | [STRING_WITH_LENGTH_256] |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.description must have between 1 and 255 characters
            """
