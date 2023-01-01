@api.system
@deactivateWeekSystem
Feature: System API - deactivateWeekSystem

  As an admin
  I want to deactivate the weekly chores generation on a specific week


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
    And the field "week_id" with value "2022.01"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario: The admin deactivates the weekly chores generation on a specific week
    Given I use the admin API key
    And the field "week_id" with value "2022.01"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the Api response contains the expected data


  Scenario Outline: Validate multiweek syntax support
    Given I use the admin API key
    And the field "week_id" with value "<week_id>"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the Api response contains the expected data
      """
      {
        "week_id": "<real_week_id>"
      }
      """

    Examples: week_id = <week_id> | real_week_id = <real_week_id>
      | week_id | real_week_id          |
      | next    | [NOW(%Y.%W) + 7 DAYS] |
      | current | [NOW(%Y.%W)]          |
      | last    | [NOW(%Y.%W) - 7 DAYS] |


  Scenario Outline: Validate error response when the week_id is invalid
    Given I use the admin API key
    And the field "week_id" with value "<week_id>"
    When I send a request to the Api
    Then the response status code is "422"
    And the response status code is defined
    And the response contains the following validation errors
      | location | param   | msg                                                          |
      | path     | week_id | string does not match regex "[CONF:patterns.weekIdExtended]" |

    Examples: week_id = <week_id>
      | week_id      |
      | invalid-week |
      | 2022-03      |
      | 2022.3       |
      | 2022.00      |
      | 2022.55      |
      | 2022023      |
      | whatever     |


  Scenario Outline: Validate error response when deactivating a week that has chores created
    Given there is 1 user, 1 chore type and weekly chores for the week "<week_id_1>"
    And I use the admin API key
    And the header language is set to "<lang>"
    And the field "week_id" with value "<week_id_2>"
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: week_id_1 = <week_id_1> | week_id_2 = <week_id_2> | lang = <lang> | err_msg = <err_msg>
      | week_id_1 | week_id_2 | lang     | err_msg                                                 |
      | 2022.01   | 2022.01   | en       | Chores exist for week 2022.01                           |
      | 2022.01   | 2022.01   | es       | Ya hay tareas creadas para la semana 2022.01            |
      | 2022.01   | 2022.01   | whatever | Chores exist for week 2022.01                           |
      | 2022.04   | 2022.01   | en       | Chores exist after week 2022.01                         |
      | 2022.04   | 2022.01   | es       | Ya hay tareas creadas para después de la semana 2022.01 |
      | 2022.04   | 2022.01   | whatever | Chores exist after week 2022.01                         |


  Scenario Outline: Validate error response when deactivating a week twice
    Given I use the admin API key
    And the field "week_id" with value "2022.01"
    And the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    When I send a request to the Api
    Then the response status code is "409"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                               |
      | en       | Week 2022.01 is already deactivated   |
      | es       | La semana 2022.01 ya está desactivada |
      | whatever | Week 2022.01 is already deactivated   |


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
