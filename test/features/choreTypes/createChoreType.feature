@api.chore-types
@createChoreType
Feature: Chore Types API - createChoreType

  As a flat admin admin
  I want to register chore types


  @authorization
  Scenario: Validate response for guest
    When I send a request to the Api with body params
      | param_name  | param_value              |
      | id          | chore-type-a             |
      | name        | chore-type-a             |
      | description | description-chore-type-a |
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "Missing API key"
    And the response error message is defined


  @authorization
  Scenario: Validate response for user
    Given I create a flat with a user and I use the user API key
    When I send a request to the Api with body params
      | param_name  | param_value              |
      | id          | chore-type-a             |
      | name        | chore-type-a             |
      | description | description-chore-type-a |
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "Flat administration access required"
    And the response error message is defined


  @authorization
  Scenario: Validate response for flat admin
    Given I create a flat and I use the flat API key
    When I send a request to the Api with body params
      | param_name  | param_value              |
      | id          | chore-type-a             |
      | name        | chore-type-a             |
      | description | description-chore-type-a |
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given I create a flat
    And I use the admin API key
    And the "[CONTEXT:created_flat_name]" as X-Flat header
    When I send a request to the Api with body params
      | param_name  | param_value              |
      | id          | chore-type-a             |
      | name        | chore-type-a             |
      | description | description-chore-type-a |
    Then the response status code is "200"
    And the response status code is defined


  Scenario: Create a chore type without users
    Given I create a flat and I use the flat API key
    When I send a request to the Api with body params
      | param_name  | param_value              |
      | id          | chore-type-a             |
      | name        | chore-type-a             |
      | description | description-chore-type-a |
    Then the response status code is "200"
    And the response body is validated against the json-schema
    When I send a request to the Api resource "listChoreTypes"
    Then the response status code is "200"
    And the Api response contains the expected data
      """
      [
        {
          "id": "chore-type-a",
          "name": "chore-type-a",
          "description": "description-chore-type-a"
        }
      ]
      """
  # TODO: enable when creating listTickets operation
  # And the database contains the following tickets


  Scenario: Validate that tickets are created after the chore type
    Given I create a flat
    And there are 3 tenants
    And I use the flat API key
    When I send a request to the Api with body params
      | param_name  | param_value           |
      | id          | new-chore             |
      | name        | new-chore             |
      | description | new-chore-description |
    Then the response status code is "200"
    And the response body is validated against the json-schema
    When I send a request to the Api resource "listChoreTypes"
    Then the response status code is "200"
    And the Api response contains the expected data
      """
      [
        {
          "id": "new-chore",
          "name": "new-chore",
          "description": "new-chore-description"
        }
      ]
      """
  # TODO: enable when creating listTickets operation
  # And the database contains the following tickets
  #     | tenant  | new-chore |
  #     | tenant1 | 0         |
  #     | tenant2 | 0         |
  #     | tenant3 | 0         |


  Scenario: Validate error response when sending an invalid body
    When I send a request to the Api with body
      """
      xxx
      """
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Request body is not a valid JSON"
    And the response error message is defined


  Scenario: Validate error response when creating a duplicated chore type
    Given I create a flat and I use the flat API key
    When I send a request to the Api with body params
      | param_name  | param_value            |
      | id          | chore-type-id          |
      | name        | chore-type-name        |
      | description | chore-type-description |
    Then the response status code is "200"
    When I send a request to the Api with body params
      | param_name  | param_value            |
      | id          | chore-type-id          |
      | name        | chore-type-name        |
      | description | chore-type-description |
    Then the response status code is "409"
    And the response status code is defined
    And the error message is "Chore type already exists"
    And the response error message is defined


  Scenario: Create two chore types with same id in different flats
    Given I create a flat and I use the flat API key
    Given the field "flat_name_1" saved as "created_flat_name"
    When I send a request to the Api with body params
      | param_name  | param_value            |
      | id          | chore-type-id          |
      | name        | chore-type-name        |
      | description | chore-type-description |
    Then the response status code is "200"
    Given I create a flat and I use the flat API key
    Given the field "flat_name_2" saved as "created_flat_name"
    When I send a request to the Api with body params
      | param_name  | param_value            |
      | id          | chore-type-id          |
      | name        | chore-type-name        |
      | description | chore-type-description |
    Then the response status code is "200"
    And the response status code is defined
    Given I use the admin API key
    And the field "chore_type_id" with value "chore-type-id"
    And the "[CONTEXT:flat_name_1]" as X-Flat header
    When I send a request to the Api resource "getChoreType"
    Then the response status code is "200"
    Given the "[CONTEXT:flat_name_2]" as X-Flat header
    When I send a request to the Api resource "getChoreType"
    Then the response status code is "200"


  Scenario Outline: Validate error response when missing required fields
    Given I create a flat and I use the flat API key
    When I send a request to the Api with body params
      | param_name  | param_value   |
      | id          | <id>          |
      | name        | <name>        |
      | description | <description> |
    Then the response status code is "422"
    And the response status code is defined
    And the response contains the following validation errors
      | location | param   | msg   | value   |
      | body     | <param> | <msg> | <value> |

    And the response error message is defined

    Examples: id = <id>, name = <name>, description = <description>, param = <param>, msg = <msg>, value = <value>
      | id                      | name                    | description              | param       | msg                                                               | value                    |
      | [NONE]                  | ct-name                 | ct-description           | id          | body.id is required                                               | [NONE]                   |
      | [NULL]                  | ct-name                 | ct-description           | id          | body.id is required                                               | [NULL]                   |
      | ct-id                   | [NONE]                  | ct-description           | name        | body.name is required                                             | [NONE]                   |
      | ct-id                   | [NULL]                  | ct-description           | name        | body.name is required                                             | [NULL]                   |
      | ct-id                   | ct-name                 | [NONE]                   | description | body.description is required                                      | [NONE]                   |
      | ct-id                   | ct-name                 | [NULL]                   | description | body.description is required                                      | [NULL]                   |
      | [EMPTY]                 | ct-name                 | ct-description           | id          | body.id must be between 1 and 25 characters long                  | [EMPTY]                  |
      | Invalid                 | ct-name                 | ct-description           | id          | body.id does not match the pattern '[CONF:pattern.chore_type_id]' | Invalid                  |
      | [STRING_WITH_LENGTH_26] | ct-name                 | ct-description           | id          | body.id must be between 1 and 25 characters long                  | [STRING_WITH_LENGTH_26]  |
      | ct-id                   | [EMPTY]                 | ct-description           | name        | body.name must be between 1 and 50 characters long                | [EMPTY]                  |
      | ct-id                   | [B]                     | ct-description           | name        | body.name must be between 1 and 50 characters long                | [EMPTY]                  |
      | ct-id                   | [STRING_WITH_LENGTH_51] | ct-description           | name        | body.name must be between 1 and 50 characters long                | [STRING_WITH_LENGTH_51]  |
      | ct-id                   | ct-name                 | [EMPTY]                  | description | body.description must be between 1 and 255 characters long        | [EMPTY]                  |
      | ct-id                   | ct-name                 | [B]                      | description | body.description must be between 1 and 255 characters long        | [EMPTY]                  |
      | ct-id                   | ct-name                 | [STRING_WITH_LENGTH_256] | description | body.description must be between 1 and 255 characters long        | [STRING_WITH_LENGTH_256] |



  Scenario: Create a chore type with the largest id possible
    Given I create a flat and I use the flat API key
    When I send a request to the Api with body params
      | param_name  | param_value              |
      | id          | [STRING_WITH_LENGTH_25]  |
      | name        | chore-type-a             |
      | description | description-chore-type-a |
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema
    When I send a request to the Api resource "listChoreTypes"
    Then the response status code is "200"
    And the Api response contains the expected data
      """
      [
        {
          "id": "[STRING_WITH_LENGTH_25]",
          "name": "chore-type-a",
          "description": "description-chore-type-a"
        }
      ]
      """


  Scenario: Create a choreType with the largest name possible
    Given I create a flat and I use the flat API key
    When I send a request to the Api with body params
      | param_name  | param_value              |
      | id          | chore-type-a             |
      | name        | [STRING_WITH_LENGTH_50]  |
      | description | description-chore-type-a |
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema
    When I send a request to the Api resource "listChoreTypes"
    Then the response status code is "200"
    And the Api response contains the expected data
      """
      [
        {
          "id": "chore-type-a",
          "name": "[STRING_WITH_LENGTH_50]",
          "description": "description-chore-type-a"
        }
      ]
      """


  Scenario: Create a choreType with the largest description possible
    Given I create a flat and I use the flat API key
    When I send a request to the Api with body params
      | param_name  | param_value              |
      | id          | chore-type-a             |
      | name        | chore-type-a             |
      | description | [STRING_WITH_LENGTH_255] |
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema
    When I send a request to the Api resource "listChoreTypes"
    Then the response status code is "200"
    And the Api response contains the expected data
      """
      [
        {
          "id": "chore-type-a",
          "name": "chore-type-a",
          "description": "[STRING_WITH_LENGTH_255]"
        }
      ]
      """


  Scenario Outline: Validate X-Correlator injection
    Given the <correlator> as X-Correlator header
    When I send a request to the Api
    Then the X-Correlator sent is the same as the X-Correlator in the response

    Examples: correlator = <correlator>
      | correlator   |
      | [UUIDv1]     |
      | [UUIDv4]     |
      | [RANDOMSTR]  |
      | 12 4AbC 1234 |
      | *_?          |


  Scenario: Validate X-Powered-By disabled
    When I send a request to the Api
    Then the header "X-Powered-By" is not present in the response
