Feature: Chore Types API - createChoreType
    Scenario: Create a chore type
        When I create the following chore type using the API
            | id           | description              |
            | chore-type-1 | description-chore-type-1 |
        Then the response status code is "200"
        And the response body is validated against the json-schema "chore-type"
        And I list the chore types using the API
        And the response contains the following chore types
            | id           | description              |
            | chore-type-1 | description-chore-type-1 |


    Scenario: Validate error creating a choreType with a null id
        When I create the following chore type using the API
            | id     | description              |
            | [NULL] | description-chore-type-1 |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.id cannot be null
            """


    Scenario: Validate error creating a choreType with an empty id
        When I create the following chore type using the API
            | id      | description              |
            | [EMPTY] | description-chore-type-1 |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.id cannot be blank
            """


    Scenario: Validate error creating a choreType with a blank id
        When I create the following chore type using the API
            | id  | description              |
            | [B] | description-chore-type-1 |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.id cannot be blank
            """


    Scenario: Validate error creating a choreType with an id too long
        When I create the following chore type using the API
            | id                         | description              |
            | 01234567890123456789012345 | description-chore-type-1 |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.id must have between 1 and 25 characters
            """


    Scenario: Validate error creating a choreType with a null description
        When I create the following chore type using the API
            | id           | description |
            | chore-type-1 | [NULL]      |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.description cannot be null
            """


    Scenario: Validate error creating a choreType with a empty description
        When I create the following chore type using the API
            | id           | description |
            | chore-type-1 | [EMPTY]     |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.description cannot be blank
            """

    Scenario: Validate error creating a choreType with a empty description
        When I create the following chore type using the API
            | id           | description |
            | chore-type-1 | [B]         |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.description cannot be blank
            """


    Scenario: Validate error creating a choreType with a description too long
        When I create the following chore type using the API
            | id           | description              |
            | chore-type-1 | [256_LEN_STR] |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            choreType.description must have between 1 and 255 characters
            """
