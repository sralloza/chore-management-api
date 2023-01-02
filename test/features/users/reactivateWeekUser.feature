@api.users
@reactivateWeekUser
Feature: Users API - reactivateWeekUser

  As an admin or user
  I want to add a user or myself to the weekly chores assigments after removing it


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
    Given there is 1 user
    And I deactivate the chore creation for the week "2025.01" and user "user-1"
    And the fields
      | field   | value   |
      | user_id | user-1  |
      | week_id | 2025.01 |
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "200"


  @authorization
  Scenario: Validate response for admin
    Given there is 1 user
    And I deactivate the chore creation for the week "2025.01" and user "user-1"
    And the fields
      | field   | value   |
      | user_id | user-1  |
      | week_id | 2025.01 |
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"


  Scenario Outline: A user reactivates user creation for a single week
    Given there are 3 users
    And there are 3 chore types
    And I deactivate the chore creation for the week "2025.01" and user "<real_user_id>"
    And the field "user_id" with value "<user_id>"
    And I use the token of the user with id "<real_user_id>"
    And the field "week_id" with value "2025.01"
    When I send a request to the Api
    Then the response status code is "200"
    Given I create the weekly chores for the week "2025.01" using the API
    Then the database contains the following weekly chores
      | week_id | A | B | C |
      | 2025.01 | 1 | 2 | 3 |

    Examples: user_id = <user_id> | real_user_id = <real_user_id>
      | user_id | real_user_id |
      | user-2  | user-2       |
      | me      | user-2       |


  Scenario Outline: Validate multiweek syntax support
    Given there are 3 users
    And there are 3 chore types
    And I deactivate the chore creation for the week "<real_week_id>" and user "user-2"
    And the fields
      | field   | value     | as_string |
      | user_id | user-2    | false     |
      | week_id | <week_id> | true      |
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    Given I create the weekly chores for the week "<real_week_id>" using the API
    And the database contains the following weekly chores
      | week_id        | A | B | C |
      | <real_week_id> | 1 | 2 | 3 |

    Examples: week_id = <week_id> | real_week_id = <real_week_id>
      | week_id | real_week_id          |
      | 2025.01 | 2025.01               |
      | next    | [NOW(%Y.%W) + 7 DAYS] |
      | current | [NOW(%Y.%W)]          |
      | last    | [NOW(%Y.%W) - 7 DAYS] |


  Scenario Outline: Validate error response when reactivated user creation for an invalid week
    Given there is 1 user, 1 chore type and weekly chores for the week "2022.05"
    And I deactivate the chore creation for the week "2022.05" and user "user-1" editing the database
    And the header language is set to "<lang>"
    And I use the admin API key
    And the fields
      | field   | value     |
      | user_id | user-1    |
      | week_id | <week_id> |
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "<err_msg>"

    Examples: week_id = <week_id> | lang = <lang> | err_msg = <err_msg>
      | week_id | lang     | err_msg                                                 |
      | 2022.05 | en       | Chores exist for week 2022.05                           |
      | 2022.05 | es       | Ya hay tareas creadas para la semana 2022.05            |
      | 2022.05 | whatever | Chores exist for week 2022.05                           |
      | 2022.01 | en       | Chores exist after week 2022.01                         |
      | 2022.01 | es       | Ya hay tareas creadas para después de la semana 2022.01 |
      | 2022.01 | whatever | Chores exist after week 2022.01                         |


  Scenario Outline: Validate error response when using keyword me with the admin token
    Given there is 1 user
    And I use the admin API key
    And the header language is set to "<lang>"
    And the fields
      | field   | value   |
      | user_id | me      |
      | week_id | 2022.01 |
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                                            |
      | en       | Can't use the special keyword me with the admin API key                            |
      | es       | No se puede usar la palabra clave especial me con la clave de API de administrador |
      | whatever | Can't use the special keyword me with the admin API key                            |


  Scenario Outline: Validate error response when requesting other user's data
    Given there are 2 users
    And I use the token of the user with id "user-1"
    And the header language is set to "<lang>"
    And the fields
      | field   | value   |
      | user_id | user-2  |
      | week_id | 2022.01 |
    When I send a request to the Api
    Then the response status code is "403"
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                    |
      | en       | You don't have permission to access this user's data       |
      | es       | No tienes permiso para acceder a los datos de este usuario |
      | whatever | You don't have permission to access this user's data       |


  Scenario Outline: Validate error response when reactivating chore creation for a non skipped week
    Given there is 1 user
    And the header language is set to "<lang>"
    And the fields
      | field   | value   |
      | user_id | user-1  |
      | week_id | 2025.01 |
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "409"
    And the error message is "<err_msg>"

    Examples: lang = <lang>
      | lang     | err_msg                                                          |
      | en       | Week 2025.01 is already activated for user with id=user-1        |
      | es       | La semana 2025.01 ya está activada para el usuario con id=user-1 |
      | whatever | Week 2025.01 is already activated for user with id=user-1        |


  Scenario Outline: Validate error response when reactivating chore creation for a syntactically invalid week
    Given there is 1 user
    And the fields
      | field   | value     | as_string |
      | user_id | user-1    | false     |
      | week_id | <week_id> | true      |
    And I use the token of the user with id "user-1"
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
