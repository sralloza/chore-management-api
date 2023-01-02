@api.weekly-chores
@getWeeklyChores
Feature: Weekly Chores API - getWeeklyChores

  As an admin or user
  I want to get the detils of the weekly chores given a specific week


  @authorization
  Scenario Outline: Validate response for unauthorized user
    Given I use a random API key
    And the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                     |
      | en       | User access required        |
      | es       | Acceso de usuario requerido |
      | whatever | User access required        |


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
  Scenario: Validate response for user
    Given there is 1 user, 1 chore type and weekly chores for the week "2022.01"
    And the field "week_id" with string value "2022.01"
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given there is 1 user, 1 chore type and weekly chores for the week "2022.01"
    And the field "week_id" with string value "2022.01"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario Outline: Get weekly chores by week_id
    Given there is 1 user, 1 chore type and weekly chores for the week "<real_week_id>"
    And I use the token of the user with id "user-1"
    And the field "week_id" with string value "<week_id>"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema
    And the response contains the following weekly chores
      | week_id        | A |
      | <real_week_id> | 1 |

    Examples: week_id = <week_id> | real_week_id = <real_week_id>
      | week_id | real_week_id          |
      | next    | [NOW(%Y.%W) + 7 DAYS] |
      | current | [NOW(%Y.%W)]          |
      | last    | [NOW(%Y.%W) - 7 DAYS] |


  Scenario Outline: Validate error response when weekly chores not found
    Given I use the admin API key
    And the field "week_id" with value "2022.01"
    And the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                 |
      | en       | No weekly chores found for week 2022.01 |
      | es       | No hay tareas para la semana 2022.01    |
      | whatever | No weekly chores found for week 2022.01 |


  Scenario Outline: Validate error response when trying to get weekly chores by an invalid week_id
    Given the field "week_id" with string value "<week_id>"
    And I use the admin API key
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
