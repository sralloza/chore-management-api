@api.system
@reactivateWeekSystem
Feature: System API - reactivateWeekSystem

  As an admin
  After I deactivate the weekly chores generation on a specific week
  I want to reactivate the weekly chores generation on a specific week


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
    Given I deactivate the chore creation for the week "2022.01"
    And I use the admin API key
    And the field "week_id" with value "2022.01"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario: The admin reactivates the weekly chores generation on a specific week
    Given I deactivate the chore creation for the week "2022.01"
    And I use the admin API key
    And the field "week_id" with value "2022.01"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the Api response contains the expected data


  Scenario Outline: Validate multiweek syntax support
    Given I deactivate the chore creation for the week "<real_week_id>"
    And I use the admin API key
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


  Scenario Outline: Validate error response when reactivating a week is not deactivated
    Given I use the admin API key
    And the header language is set to "<lang>"
    And the field "week_id" with value "<week_id_2>"
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: week_id_1 = <week_id_1> | week_id_2 = <week_id_2> | lang = <lang> | err_msg = <err_msg>
      | week_id_1 | week_id_2 | lang     | err_msg                               |
      | 2022.01   | 2022.01   | en       | Week 2022.01 is already deactivated   |
      | 2022.01   | 2022.01   | es       | La semana 2022.01 ya está deactivated |
      | 2022.01   | 2022.01   | whatever | Week 2022.01 is already deactivated   |
      | 2022.04   | 2022.01   | en       | Week 2022.01 is already deactivated   |
      | 2022.04   | 2022.01   | es       | La semana 2022.01 ya está deactivated |
      | 2022.04   | 2022.01   | whatever | Week 2022.01 is already deactivated   |


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
