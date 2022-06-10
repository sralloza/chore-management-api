@chore-type
@crud.create
Feature: Chore Types API - createChoreType

    As an admin I want to register chore types.

    # TODO: validate only admin can register chore types (guests and tenants are not allowed).

    Scenario: Create a chore type without tenants
        When I create a chore type type using the API
            | id           | description              |
            | chore-type-1 | description-chore-type-1 |
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type"
        And the database contains the following chore types
            | id           | description              |
            | chore-type-1 | description-chore-type-1 |
        And the database contains the following tickets


    Scenario: Validate that tickets are created after the chore type
        Given there are 3 tenants
        When I create a chore type type using the API
            | id        | description           |
            | new-chore | new-chore-description |
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type"
        And the database contains the following chore types
            | id        | description           |
            | new-chore | new-chore-description |
        And the database contains the following tickets
            | tenant  | new-chore |
            | tenant1 | 0         |
            | tenant2 | 0         |
            | tenant3 | 0         |


    Scenario: Validate error creating a chore type with a null id
        When I create a chore type type using the API
            | id     | description              |
            | [NULL] | description-chore-type-1 |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.id cannot be null
            """


    Scenario: Validate error creating a chore type with an empty id
        When I create a chore type type using the API
            | id      | description              |
            | [EMPTY] | description-chore-type-1 |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.id cannot be blank
            """


    Scenario: Validate error creating a chore type with a blank id
        When I create a chore type type using the API
            | id  | description              |
            | [B] | description-chore-type-1 |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.id cannot be blank
            """


    Scenario: create a chore type with the largest id possible
        When I create a chore type type using the API
            | id           | description              |
            | [25_LEN_STR] | description-chore-type-1 |
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type"
        And the database contains the following chore types
            | id           | description              |
            | [25_LEN_STR] | description-chore-type-1 |


    Scenario: Validate error creating a chore type with an id too long
        When I create a chore type type using the API
            | id           | description              |
            | [26_LEN_STR] | description-chore-type-1 |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.id must have between 1 and 25 characters
            """


    Scenario: Validate error creating a chore type with a null description
        When I create a chore type type using the API
            | id           | description |
            | chore-type-1 | [NULL]      |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.description cannot be null
            """


    Scenario: Validate error creating a chore type with an empty description
        When I create a chore type type using the API
            | id           | description |
            | chore-type-1 | [EMPTY]     |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.description cannot be blank
            """


    Scenario: Validate error creating a choreType with a blank description
        When I create a chore type type using the API
            | id           | description |
            | chore-type-1 | [B]         |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.description cannot be blank
            """


    Scenario: create a choreType with the largest description possible
        When I create a chore type type using the API
            | id           | description   |
            | chore-type-1 | [255_LEN_STR] |
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type"
        And the database contains the following chore types
            | id           | description   |
            | chore-type-1 | [255_LEN_STR] |


    Scenario: Validate error creating a choreType with a description too long
        When I create a chore type type using the API
            | id           | description   |
            | chore-type-1 | [256_LEN_STR] |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.description must have between 1 and 255 characters
            """
