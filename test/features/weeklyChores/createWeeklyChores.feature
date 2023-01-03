@api.weekly-chores
@createWeeklyChores
Feature: Weekly Chores API - createWeeklyChores

  As an admin
  I want to create the weekly chores


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
  Scenario: Validate response for admin user
    Given there is 1 user
    And there is 1 chore type
    And the field "week_id" with string value "2022.01"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario: Create weekly chores when same number of users and chore types (postive rotation)
    Given there are 4 users
    And there are 4 chore types
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2022.01 |
      | 2022.02 |
      | 2022.03 |
      | 2022.04 |
      | 2022.15 |
      | 2022.16 |
      | 2022.17 |
      | 2022.18 |
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B | C | D |
      | 2022.01 | 1 | 2 | 3 | 4 |
      | 2022.02 | 2 | 3 | 4 | 1 |
      | 2022.03 | 3 | 4 | 1 | 2 |
      | 2022.04 | 4 | 1 | 2 | 3 |
      | 2022.15 | 1 | 2 | 3 | 4 |
      | 2022.16 | 2 | 3 | 4 | 1 |
      | 2022.17 | 3 | 4 | 1 | 2 |
      | 2022.18 | 4 | 1 | 2 | 3 |


  Scenario: Create weekly chores when same number of users and chore types (negative rotation)
    Given there are 4 users
    And there are 4 chore types
    And I use the admin API key
    When I send a request to the Api resource "editSystemSettings" with body params
      | param_name    | param_value |
      | rotation_sign | negative    |
    Then the response status code is "200"
    Given I create the weekly chores for the following weeks using the API
      | week_id |
      | 2022.01 |
      | 2022.02 |
      | 2022.03 |
      | 2022.04 |
      | 2022.15 |
      | 2022.16 |
      | 2022.17 |
      | 2022.18 |
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B | C | D |
      | 2022.01 | 1 | 2 | 3 | 4 |
      | 2022.02 | 4 | 1 | 2 | 3 |
      | 2022.03 | 3 | 4 | 1 | 2 |
      | 2022.04 | 2 | 3 | 4 | 1 |
      | 2022.15 | 1 | 2 | 3 | 4 |
      | 2022.16 | 4 | 1 | 2 | 3 |
      | 2022.17 | 3 | 4 | 1 | 2 |
      | 2022.18 | 2 | 3 | 4 | 1 |


  Scenario: Create weekly chores when there are more users than chore types
    Given there are 5 users
    And there are 3 chore types
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2022.01 |
      | 2022.02 |
      | 2022.03 |
      | 2022.04 |
      | 2022.15 |
      | 2022.16 |
      | 2022.17 |
      | 2022.18 |
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B | C |
      | 2022.01 | 1 | 2 | 3 |
      | 2022.02 | 2 | 3 | 4 |
      | 2022.03 | 3 | 4 | 5 |
      | 2022.04 | 4 | 5 | 1 |
      | 2022.15 | 5 | 1 | 2 |
      | 2022.16 | 1 | 2 | 3 |
      | 2022.17 | 2 | 3 | 4 |
      | 2022.18 | 3 | 4 | 5 |


  Scenario: Create weekly chores when there are more chore types than users
    Given there are 3 users
    And there are 5 chore types
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2022.01 |
      | 2022.02 |
      | 2022.03 |
      | 2022.04 |
      | 2022.15 |
      | 2022.16 |
      | 2022.17 |
      | 2022.18 |
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B | C | D | E |
      | 2022.01 | 1 | 2 | 3 | 1 | 2 |
      | 2022.02 | 2 | 3 | 1 | 2 | 3 |
      | 2022.03 | 3 | 1 | 2 | 3 | 1 |
      | 2022.04 | 1 | 2 | 3 | 1 | 2 |
      | 2022.15 | 2 | 3 | 1 | 2 | 3 |
      | 2022.16 | 3 | 1 | 2 | 3 | 1 |
      | 2022.17 | 1 | 2 | 3 | 1 | 2 |
      | 2022.18 | 2 | 3 | 1 | 2 | 3 |


  Scenario: Create weekly chores when a user deactivates its chores assignment in a specific week
    Given there are 4 users
    And there are 4 chore types
    And the user with id "user-2" deactivates its chores assigments for the week "2025.15"
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2025.01 |
      | 2025.02 |
      | 2025.03 |
      | 2025.04 |
      | 2025.15 |
      | 2025.16 |
      | 2025.17 |
      | 2025.18 |
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B     | C | D |
      | 2025.01 | 1 | 2     | 3 | 4 |
      | 2025.02 | 2 | 3     | 4 | 1 |
      | 2025.03 | 3 | 4     | 1 | 2 |
      | 2025.04 | 4 | 1     | 2 | 3 |
      | 2025.15 | 1 | 1,3,4 | 3 | 4 |
      | 2025.16 | 2 | 3     | 4 | 1 |
      | 2025.17 | 3 | 4     | 1 | 2 |
      | 2025.18 | 4 | 1     | 2 | 3 |


  Scenario: Create weekly chores when two users deactivates their chore assigments
    Given there are 4 users
    And there are 4 chore types
    And the user with id "user-2" deactivates its chores assigments for the week "2025.15"
    And the user with id "user-3" deactivates its chores assigments for the week "2025.15"
    And the user with id "user-3" deactivates its chores assigments for the week "2025.16"
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2025.01 |
      | 2025.02 |
      | 2025.03 |
      | 2025.04 |
      | 2025.15 |
      | 2025.16 |
      | 2025.17 |
      | 2025.18 |
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B     | C   | D |
      | 2025.01 | 1 | 2     | 3   | 4 |
      | 2025.02 | 2 | 3     | 4   | 1 |
      | 2025.03 | 3 | 4     | 1   | 2 |
      | 2025.04 | 4 | 1     | 2   | 3 |
      | 2025.15 | 1 | 1,4   | 1,4 | 4 |
      | 2025.16 | 2 | 1,2,4 | 4   | 1 |
      | 2025.17 | 3 | 4     | 1   | 2 |
      | 2025.18 | 4 | 1     | 2   | 3 |


  Scenario: Create weekly chores when all users deactivates their chore assigments for a specific week
    Given there are 4 users
    And there are 4 chore types
    And the user with id "user-1" deactivates its chores assigments for the week "2025.15"
    And the user with id "user-2" deactivates its chores assigments for the week "2025.15"
    And the user with id "user-4" deactivates its chores assigments for the week "2025.15"
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2025.01 |
      | 2025.02 |
      | 2025.03 |
      | 2025.04 |
      | 2025.15 |
      | 2025.16 |
      | 2025.17 |
      | 2025.18 |
    And I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B | C | D |
      | 2025.01 | 1 | 2 | 3 | 4 |
      | 2025.02 | 2 | 3 | 4 | 1 |
      | 2025.03 | 3 | 4 | 1 | 2 |
      | 2025.04 | 4 | 1 | 2 | 3 |
      | 2025.15 | 3 | 3 | 3 | 3 |
      | 2025.16 | 1 | 2 | 3 | 4 |
      | 2025.17 | 2 | 3 | 4 | 1 |
      | 2025.18 | 3 | 4 | 1 | 2 |


  Scenario Outline: Validate multiweek syntax support
    Given there are 4 users
    And there are 4 chore types
    And the field "week_id" with string value "<week_id>"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id        | A | B | C | D |
      | <real_week_id> | 1 | 2 | 3 | 4 |

    Examples:
      | week_id | real_week_id          |
      | next    | [NOW(%Y.%W) + 7 DAYS] |
      | current | [NOW(%Y.%W)]          |
      | last    | [NOW(%Y.%W) - 7 DAYS] |


  Scenario Outline: Validate error response when creating weekly chores for a system deactivated week
    Given there is 1 user
    And the header language is set to "<lang>"
    And there is 1 chore type
    And I use the admin API key
    And the field "week_id" with string value "2022.01"
    When I send a request to the Api resource "deactivateWeekSystem"
    Then the response status code is "200"
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples:
      | lang     | err_msg                            |
      | en       | Week 2022.01 is deactivated        |
      | es       | La semana 2022.01 está desactivada |
      | whatever | Week 2022.01 is deactivated        |


  Scenario Outline: Validate error response when creating duplicate weekly chores
    Given there is 1 user
    And the header language is set to "<lang>"
    And there is 1 chore type
    And the field "week_id" with string value "2022.01"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    When I send a request to the Api
    Then the response status code is "409"
    And the response status code is defined
    And the error message contains "<err_msg>"

    Examples:
      | lang     | err_msg                                      |
      | en       | Weekly chores for week 2022.01 already exist |
      | es       | Ya hay tareas creadas para la semana 2022.01 |
      | whatever | Weekly chores for week 2022.01 already exist |


  Scenario Outline: Validate error response when creating weekly chores for an old week
    Given there is 1 user, 1 chore type and weekly chores for the week "[NOW(%Y.%W)]"
    And the field "week_id" with string value "<week_id>"
    And the header language is set to "<lang>"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: week_id = <week_id> | parsed_week_id = <parsed_week_id> | lang = <lang> | err_msg = <err_msg>
      | week_id | parsed_week_id        | lang     | err_msg                                                               |
      | 2020.01 | 2020.01               | en       | Chores exist after week 2020.01                                       |
      | 2020.01 | 2020.01               | es       | Ya hay tareas creadas para después de la semana 2020.01               |
      | 2020.01 | 2020.01               | whatever | Chores exist after week 2020.01                                       |
      | last    | [NOW(%Y.%W) - 7 DAYS] | en       | Chores exist after week [NOW(%Y.%W) - 7 DAYS]                         |
      | last    | [NOW(%Y.%W) - 7 DAYS] | es       | Ya hay tareas creadas para después de la semana [NOW(%Y.%W) - 7 DAYS] |
      | last    | [NOW(%Y.%W) - 7 DAYS] | whatever | Chores exist after week [NOW(%Y.%W) - 7 DAYS]                         |


  Scenario Outline: Validate error response when creating weekly chores after users have changed
    Given there are 3 users
    And there are 3 chore types
    And the header language is set to "<lang>"
    And I create the weekly chores for the week "2022.01" using the API
    And I use the admin API key
    When I send a request to the Api resource "createUser" with body params
      | param_name | param_value |
      | username   | John        |
      | id         | 1111        |
    Then the response status code is "200"
    Given the field "week_id" with string value "2022.02"
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                                 |
      | en       | Users have changed since last weekly chores creation                    |
      | es       | Los usuarios han cambiado desde la última vez que se crearon las tareas |
      | whatever | Users have changed since last weekly chores creation                    |


  Scenario: Validate force creation of weekly chores after users have changed
    Given there are 3 users
    And there are 3 chore types
    And I create the weekly chores for the week "2022.01" using the API
    And I use the admin API key
    When I send a request to the Api resource "createUser" with body params
      | param_name | param_value |
      | username   | John        |
      | id         | 1111        |
    Then the response status code is "200"
    Given the field "week_id" with string value "2022.02"
    And the parameters to filter the request
      | param_name | param_value |
      | force      | true        |
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema



  Scenario Outline: Validate error response when creating weekly chores after chore types have changed
    Given there are 3 users
    And there are 3 chore types
    And the header language is set to "<lang>"
    And I create the weekly chores for the week "2022.01" using the API
    And I use the admin API key
    When I send a request to the Api resource "createChoreType" with body params
      | param_name  | param_value              |
      | id          | ct-x                     |
      | name        | chore type x             |
      | description | chore type x description |
    Then the response status code is "200"
    Given the field "week_id" with string value "2022.02"
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                                        |
      | en       | Chore types have changed since last weekly chores creation                     |
      | es       | Los tipos de tareas han cambiado desde la última vez que se crearon las tareas |
      | whatever | Chore types have changed since last weekly chores creation                     |


  Scenario: Validate force creation of weekly chores after chore types have changed
    Given there are 3 users
    And there are 3 chore types
    And I create the weekly chores for the week "2022.01" using the API
    And I use the admin API key
    When I send a request to the Api resource "createChoreType" with body params
      | param_name  | param_value              |
      | id          | ct-x                     |
      | name        | chore type x             |
      | description | chore type x description |
    Then the response status code is "200"
    Given the field "week_id" with string value "2022.02"
    And the parameters to filter the request
      | param_name | param_value |
      | force      | true        |
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema


  Scenario: Validate dry run mode
    Given there are 3 users
    And there are 3 chore types
    And I use the admin API key
    And the field "week_id" with string value "2022.01"
    And the parameters to filter the request
      | param_name | param_value |
      | dry_run    | true        |
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    Given the parameters to filter the request
      | param_name | param_value |
      | dry_run    | true        |
    When I send a request to the Api
    Then the response status code is "200"


  Scenario: Create weekly tasks if a user is created and deleted
    Given there are 3 users
    And there are 3 chore types
    And I create the weekly chores for the week "2022.01" using the API
    And I use the admin API key
    When I send a request to the Api resource "createUser" with body params
      | param_name | param_value |
      | username   | John        |
      | id         | john-id     |
    Then the response status code is "200"
    Given the field "user_id" with value "john-id"
    When I send a request to the Api resource "deleteUser"
    Then the response status code is "204"
    Given the field "week_id" with string value "2022.02"
    When I send a request to the Api
    Then the response status code is "200"
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B | C |
      | 2022.01 | 1 | 2 | 3 |
      | 2022.02 | 2 | 3 | 1 |


  Scenario: Force restart weekly tasks creation if new user is registered
    Given there are 3 users
    And there are 5 chore types
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2022.01 |
      | 2022.02 |
    And I use the admin API key
    When I send a request to the Api resource "createUser" with body params
      | param_name | param_value |
      | username   | username-4  |
      | id         | user-4      |
    Then the response status code is "200"
    Given the field "week_id" with string value "2022.03"
    And the parameters to filter the request
      | param_name | param_value |
      | force      | true        |
    When I send a request to the Api
    Then the response status code is "200"
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B | C | D | E |
      | 2022.01 | 1 | 2 | 3 | 1 | 2 |
      | 2022.02 | 2 | 3 | 1 | 2 | 3 |
      | 2022.03 | 1 | 2 | 3 | 4 | 1 |


  Scenario Outline: Validate error response when creating weekly chores but there are no users
    Given there is 1 chore type
    And the field "week_id" with string value "2022.01"
    And the header language is set to "<lang>"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples:
      | lang     | err_msg                                                          |
      | en       | Can't create weekly chores, no users registered                  |
      | es       | No se pueden crear tareas semanales, no hay usuarios registrados |
      | whatever | Can't create weekly chores, no users registered                  |


  Scenario Outline: Validate error response when creating weekly chores but there are no chore types
    Given there is 1 user
    And the field "week_id" with string value "2022.01"
    And the header language is set to "<lang>"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples:
      | lang     | err_msg                                                                 |
      | en       | Can't create weekly chores, no chore types registered                   |
      | es       | No se pueden crear tareas semanales, no hay tipos de tareas registrados |
      | whatever | Can't create weekly chores, no chore types registered                   |


  Scenario Outline: Validate error response when creating weekly chores for invalid week
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
