@api.chore-types
@createChoreType
Feature: Chore Types API - createChoreType

  As an admin
  I want to register chore types


  @authorization
  Scenario Outline: Validate response for unauthorized user
    Given I use a random API key
    And the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                           |
      | en       | Admin access required             |
      | es       | Acceso de administrador requerido |
      | whatever | Admin access required             |


  @authorization
  Scenario Outline: Validate response for guest
    Given the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                  |
      | en       | Missing API key          |
      | es       | Falta la clave de la API |
      | whatever | Missing API key          |


  @authorization
  Scenario Outline: Validate response for user
    Given I create a user and I use the user API key
    And the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                           |
      | en       | Admin access required             |
      | es       | Acceso de administrador requerido |
      | whatever | Admin access required             |


  @authorization
  Scenario: Validate response for admin
    Given I use the admin API key
    When I send a request to the Api with body params
      | param_name  | param_value              |
      | id          | chore-type-a             |
      | name        | chore-type-a             |
      | description | description-chore-type-a |
    Then the response status code is "200"
    And the response status code is defined


  Scenario: Create a chore type without users
    Given I use the admin API key
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
    When I send a request to the Api resource "listTickets"
    Then the response status code is "200"
    And the Api response contains the expected data
      """
      [
        {
          "id": "chore-type-a",
          "name": "chore-type-a",
          "description": "description-chore-type-a",
          "tickets_by_user_id": {},
          "tickets_by_user_name": {}
        }
      ]
      """


  Scenario: Validate that tickets are created after the chore type
    Given there are 3 users
    And I use the admin API key
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
    When I send a request to the Api resource "listTickets"
    Then the response status code is "200"
    And the Api response contains the expected data
      """
      [
        {
          "id": "new-chore",
          "name": "new-chore",
          "description": "new-chore-description",
          "tickets_by_user_id": {
            "user-1": 0,
            "user-2": 0,
            "user-3": 0
          },
          "tickets_by_user_name": {
            "username-1": 0,
            "username-2": 0,
            "username-3": 0
          }
        }
      ]
      """


  Scenario Outline: Validate error response when the payload is not a valid json
    Given the header language is set to "<lang>"
    When I send a request to the Api with body
      """
      xxx
      """
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                       |
      | en       | Request body is not a valid JSON              |
      | es       | El cuerpo de la petición no es un JSON válido |
      | whatever | Request body is not a valid JSON              |


  Scenario Outline: Validate error response when creating a duplicated chore type
    Given I use the admin API key
    And the header language is set to "<lang>"
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
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                           |
      | en       | ChoreType with id=chore-type-id already exists    |
      | es       | Ya existe un tipo de tarea con id=chore-type-id |
      | whatever | ChoreType with id=chore-type-id already exists    |


  Scenario Outline: Validate error response when missing required fields
    Given I use the admin API key
    When I send a request to the Api with body params
      | param_name  | param_value   |
      | id          | <id>          |
      | name        | <name>        |
      | description | <description> |
    Then the response status code is "422"
    And the response status code is defined
    And the response contains the following validation errors
      | location | param   | msg   |
      | body     | <param> | <msg> |

    Examples: id = <id>, name = <name>, description = <description>, param = <param>, msg = <msg>
      | id                      | name                    | description              | param       | msg                                          |
      | [NONE]                  | ct-name                 | ct-description           | id          | field required                               |
      | [NULL]                  | ct-name                 | ct-description           | id          | none is not an allowed value                 |
      | ct-id                   | [NONE]                  | ct-description           | name        | field required                               |
      | ct-id                   | [NULL]                  | ct-description           | name        | none is not an allowed value                 |
      | ct-id                   | ct-name                 | [NONE]                   | description | field required                               |
      | ct-id                   | ct-name                 | [NULL]                   | description | none is not an allowed value                 |
      | [EMPTY]                 | ct-name                 | ct-description           | id          | ensure this value has at least 1 characters  |
      | Invalid                 | ct-name                 | ct-description           | id          | string does not match regex "^[a-z-]+$"      |
      | [STRING_WITH_LENGTH_26] | ct-name                 | ct-description           | id          | ensure this value has at most 25 characters  |
      | ct-id                   | [EMPTY]                 | ct-description           | name        | ensure this value has at least 1 characters  |
      | ct-id                   | [B]                     | ct-description           | name        | ensure this value has at least 1 characters  |
      | ct-id                   | [STRING_WITH_LENGTH_51] | ct-description           | name        | ensure this value has at most 50 characters  |
      | ct-id                   | ct-name                 | [EMPTY]                  | description | ensure this value has at least 1 characters  |
      | ct-id                   | ct-name                 | [B]                      | description | ensure this value has at least 1 characters  |
      | ct-id                   | ct-name                 | [STRING_WITH_LENGTH_256] | description | ensure this value has at most 255 characters |


  Scenario: Create a chore type with the largest id possible
    Given I use the admin API key
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
    Given I use the admin API key
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
    Given I use the admin API key
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


  @common
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


  @common
  Scenario: Validate X-Correlator creation
    Given I don't include the X-Correlator header in the request
    When I send a request to the Api
    Then the X-Correlator is present in the response
