@api.system
@editSystemSettings
Feature: System API - editSystemSettings

  As an admin
  I want to edit the system's settings


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
    When I send a request to the Api with body
      """
      {}
      """
    Then the response status code is "200"
    And the response status code is defined


  Scenario Outline: Edit system settings when there is 1 user
    Given I create a user
    And I use the admin API key
    When I send a request to the Api with body params
      | param_name         | param_value     |
      | assignment_order.0 | <user_id>       |
      | rotation_sign      | <rotation_sign> |
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      {
        "assignment_order": [
          "<user_id>"
        ],
        "rotation_sign": "<rotation_sign>"
      }
      """

    Examples: user_id = <user_id>, rotation_sign = <rotation_sign>
      | user_id                   | rotation_sign |
      | [CONTEXT:created_user_id] | positive      |
      | [CONTEXT:created_user_id] | negative      |
      | [CONTEXT:created_user_id] | positive      |
      | [CONTEXT:created_user_id] | negative      |


  Scenario: Edit system settings when there are 2 users
    Given I use the admin API key
    When I send a request to the Api resource "createUser" with body params
      | param_name | param_value |
      | username   | user-1      |
      | id         | user-1      |
    Then the response status code is "200"
    When I send a request to the Api resource "createUser" with body params
      | param_name | param_value |
      | username   | user-2      |
      | id         | user-2      |
    Then the response status code is "200"
    When I send a request to the Api with body params
      | param_name         | param_value |
      | assignment_order.0 | user-2      |
      | assignment_order.1 | user-1      |
      | rotation_sign      | negative    |
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      {
        "assignment_order": [
          "user-2",
          "user-1"
        ],
        "rotation_sign": "negative"
      }
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


  Scenario Outline: Validate error response when sending invalid data
    Given I create a user
    And I use the admin API key
    When I send a request to the Api with body params
      | param_name         | param_value     |
      | assignment_order   | [LIST:[]]       |
      | assignment_order.0 | <user_id>       |
      | rotation_sign      | <rotation_sign> |
    Then the response status code is "422"
    And the response status code is defined
    And the response contains the following validation errors
      | location | param   | msg   |
      | body     | <param> | <msg> |

    Examples: user_id = <user_id>, rotation_sign = <rotation_sign>, param = <param>, msg = <msg>, value = <value>
      | user_id   | rotation_sign | param            | msg                                                                        |
      | [NONE]    | whatever      | rotation_sign    | value is not a valid enumeration member; permitted: 'positive', 'negative' |
      | [INT:123] | [NONE]        | assignment_order | assignment_order contains invalid user ids or is missing some              |
      | [NONE]    | [NONE]        | assignment_order | assignment_order contains invalid user ids or is missing some              |
      | xxxx      | [NONE]        | assignment_order | assignment_order contains invalid user ids or is missing some              |


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
