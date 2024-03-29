@api.system
@getSystemSettings
Feature: System API - getSystemSettings

  As an admin
  I want to access the system's settings


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
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario Outline: Get system settings when there is 1 user
    Given I create a user
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data

    Examples: user_id = <user_id>, rotation_sign = <rotation_sign>
      | user_id                   | rotation_sign |
      | [CONTEXT:created_user_id] | positive      |
      | [CONTEXT:created_user_id] | negative      |
      | [CONTEXT:created_user_id] | positive      |
      | [CONTEXT:created_user_id] | negative      |


  Scenario: Get system settings when there are 2 users
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
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      {
        "assignment_order": [
          "user-1",
          "user-2"
        ],
        "rotation_sign": "positive"
      }
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
