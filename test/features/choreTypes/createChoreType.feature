@api.chore-types
@createChoreType
Feature: Chore Types API - createChoreType

    As an admin
    I want to register chore types.


    Scenario: Return 403 when user is a guest
        When I send a request to the Api with body params
            | param_name  | param_value              |
            | id          | chore-type-1             |
            | description | description-chore-type-1 |
        Then the response status code is "403"
        And the error message is "Admin access required"


    Scenario: Return 403 when user is a tenant
        Given I use a tenant's token
        When I send a request to the Api with body params
            | param_name  | param_value              |
            | id          | chore-type-1             |
            | description | description-chore-type-1 |
        Then the response status code is "403"
        And the error message is "Admin access required"


    Scenario: Create a chore type without tenants
        Given I use the admin token
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
        And I use the admin token
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


    Scenario: Validate error when sending no body
        When I send a request to the Api
        Then the response status code is "400"
        And the error message is "Missing request body"


    Scenario Outline: Validate error when sending an invalid body
        When I send a request to the Api with body
            """
            <body>
            """
        Then the response status code is "400"
        And the error message is "Invalid request body"

        Examples: body = <body> | err_msg = <err_msg>
            | body       | err_msg              |
            | not-a-json | Invalid request body |
            | "string"   | Invalid request body |


    Scenario Outline: Validate error when missing required fields
        When I send a request to the Api with body params
            | param_name  | param_value   |
            | id          | <id>          |
            | description | <description> |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            <error_msg>
            """

        Examples:
            | id         | description | error_msg                            |
            | [NONE]     | description | choreType.id cannot be null          |
            | chore-type | [NONE]      | choreType.description cannot be null |



    Scenario Outline: Validate error creating a chore type with invalid fields
        When I send a request to the Api with body params
            | param_name  | param_value   |
            | id          | <id>          |
            | description | <description> |
        Then the response status code is "400"
        And one of messages in the errors array is the following
            """
            <error_msg>
            """

        Examples: id = <id> | description = <description> | error_msg = <error_msg>
            | id                      | description              | error_msg                                                    |
            | [NULL]                  | description              | choreType.id cannot be null                                  |
            | [EMPTY]                 | description              | choreType.id cannot be blank                                 |
            | [B]                     | description              | choreType.id cannot be blank                                 |
            | [STRING_WITH_LENGTH_26] | description              | choreType.id must have between 1 and 25 characters           |
            | chore-type-1            | [NULL]                   | choreType.description cannot be null                         |
            | chore-type-1            | [EMPTY]                  | choreType.description cannot be blank                        |
            | chore-type-1            | [B]                      | choreType.description cannot be blank                        |
            | chore-type-1            | [STRING_WITH_LENGTH_256] | choreType.description must have between 1 and 255 characters |


    Scenario: Create a chore type with the largest id possible
        Given I use the admin token
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


    Scenario: Create a choreType with the largest description possible
        Given I use the admin token
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
