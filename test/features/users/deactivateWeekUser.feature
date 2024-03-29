@api.users
@deactivateWeekUser
Feature: Users API - deactivateWeekUser

  As an admin or user
  I want to remove a user or myself from the weekly chores assigments


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
    Given I create a user and I use the user API key
    And the fields
      | field   | value                     |
      | user_id | [CONTEXT:created_user_id] |
      | week_id | 2022.01                   |
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given I create a user
    And I use the admin API key
    And the fields
      | field   | value                     |
      | user_id | [CONTEXT:created_user_id] |
      | week_id | 2022.01                   |
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario Outline: A user deactivates its chores assignment in a specific week
    Given there are 3 users
    And there are 3 chore types
    And the fields
      | field   | value   | as_string |
      | user_id | <user>  | false     |
      | week_id | 2022.01 | false     |
    And I use the token of the user with id "<real_user>"
    When I send a request to the Api
    Then the response status code is "200"
    And the Api response contains the expected data
    Given I create the weekly chores for the week "2022.01" using the API
    Then the database contains the following weekly chores
      | week_id | A | B   | C |
      | 2022.01 | 1 | 1,3 | 3 |

    Examples: user = <user> | real_user = <real_user>
      | user   | real_user |
      | user-2 | user-2    |
      | me     | user-2    |


  Scenario Outline: Validate multiweek syntax support
    Given there are 3 users
    And there are 3 chore types
    And the fields
      | field   | value     | as_string |
      | user_id | user-2    | false     |
      | week_id | <week_id> | true      |
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    Given I create the weekly chores for the week "<real_week_id>" using the API
    And the database contains the following weekly chores
      | week_id        | A | B   | C |
      | <real_week_id> | 1 | 1,3 | 3 |

    Examples: week_id = <week_id> | real_week_id = <real_week_id>
      | week_id | real_week_id          |
      | next    | [NOW(%Y.%W) + 7 DAYS] |
      | current | [NOW(%Y.%W)]          |
      | last    | [NOW(%Y.%W) - 7 DAYS] |


  Scenario Outline: Validate error response when accesing a non-existing user using the admin token
    Given I use the admin API key
    And the header language is set to "<lang>"
    And the fields
      | field   | value   |
      | user_id | xxx     |
      | week_id | 2022.01 |
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                             |
      | en       | User with id=xxx does not exist     |
      | es       | No existe ningún usuario con id=xxx |
      | whatever | User with id=xxx does not exist     |


  Scenario Outline: Validate error response when using keyword me with the admin token
    Given there is 1 user
    And the header language is set to "<lang>"
    And I use the admin API key
    And the fields
      | field   | value   |
      | user_id | me      |
      | week_id | 2022.01 |
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                                            |
      | en       | Can't use the special keyword me with the admin API key                            |
      | es       | No se puede usar la palabra clave especial me con la clave de API de administrador |
      | whatever | Can't use the special keyword me with the admin API key                            |


  Scenario Outline: Validate error response when requesting other user's data
    Given there are 2 users
    And the header language is set to "<lang>"
    And I use the token of the user with id "user-1"
    And the fields
      | field   | value   |
      | user_id | user-2  |
      | week_id | 2022.01 |
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang>
      | lang     | err_msg                                                    |
      | en       | You don't have permission to access this user's data       |
      | es       | No tienes permiso para acceder a los datos de este usuario |
      | whatever | You don't have permission to access this user's data       |


  Scenario Outline: Validate error response deactivating a week that already has weekly chores
    Given there is 1 user, 1 chore type and weekly chores for the week "2022.01"
    And the header language is set to "<lang>"
    And the fields
      | field   | value   | as_string |
      | user_id | user-1  | false     |
      | week_id | 2022.01 | true      |
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                      |
      | en       | Chores exist for week 2022.01                |
      | es       | Ya hay tareas creadas para la semana 2022.01 |
      | whatever | Chores exist for week 2022.01                |


  Scenario Outline: Validate error respones deactivating a week twice
    Given there is 1 user
    And the header language is set to "<lang>"
    And the fields
      | field   | value   | as_string |
      | user_id | user-1  | false     |
      | week_id | 2022.01 | true      |
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the Api response contains the expected data
    When I send a request to the Api
    Then the response status code is "409"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                             |
      | en       | Week 2022.01 is already deactivated for user with id=user-1         |
      | es       | La semana 2022.01 ya está desactivada para el usuario con id=user-1 |
      | whatever | Week 2022.01 is already deactivated for user with id=user-1         |


  Scenario Outline: Validate error response when a user skips an invalid week
    Given I create a user and I use the user API key
    And the fields
      | field   | value                     | as_string |
      | user_id | [CONTEXT:created_user_id] | false     |
      | week_id | <week_id>                 | true      |
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
