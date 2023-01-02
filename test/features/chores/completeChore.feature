@api.chores
@completeChore
Feature: Chores API - completeChore

  As a user or admin
  I want to complete a task


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
    And the fields
      | field         | value   |
      | week_id       | 2022.01 |
      | chore_type_id | ct-a    |
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "204"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given there is 1 user, 1 chore type and weekly chores for the week "2022.01"
    And the fields
      | field         | value   |
      | week_id       | 2022.01 |
      | chore_type_id | ct-a    |
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "204"
    And the response status code is defined


  Scenario Outline: Complete task happy path
    Given there are 2 users, 2 chore types and weekly chores for the week "<real_week_id>"
    And the fields
      | field         | value     |
      | week_id       | <week_id> |
      | chore_type_id | ct-a      |
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "204"
    And the Api response is empty
    When I send a request to the Api resource "listChores"
    Then the response status code is "200"
    And the Api response contains the expected data
      | skip_param   |
      | created_at   |
      | completed_at |
      | id           |
      """
      [
        {
          "chore_type_id": "ct-a",
          "done": true,
          "user_id": "user-1",
          "week_id": "<real_week_id>"
        },
        {
          "chore_type_id": "ct-b",
          "done": false,
          "user_id": "user-2",
          "week_id": "<real_week_id>"
        }
      ]
      """

    Examples: week_id = <week_id> | real_week_id = <real_week_id>
      | week_id | real_week_id          |
      | next    | [NOW(%Y.%W) + 7 DAYS] |
      | current | [NOW(%Y.%W)]          |
      | last    | [NOW(%Y.%W) - 7 DAYS] |


  Scenario Outline: Complete task assigned to two users
    Given there are 3 users
    And there are 3 chore types
    And the user with id "user-3" deactivates its chores assigments for the week "2030.01"
    And I create the weekly chores for the week "2030.01" using the API
    And the fields
      | field         | value   |
      | week_id       | 2030.01 |
      | chore_type_id | ct-c    |
    And I use the token of the user with id "<user_id>"
    When I send a request to the Api
    Then the response status code is "204"
    And the Api response is empty
    When I send a request to the Api resource "listChores"
    Then the response status code is "200"
    And the Api response contains the expected data
      | skip_param   |
      | created_at   |
      | completed_at |
      | id           |
      """
      [
        {
          "chore_type_id": "ct-a",
          "done": false,
          "user_id": "user-1",
          "week_id": "2030.01"
        },
        {
          "chore_type_id": "ct-b",
          "done": false,
          "user_id": "user-2",
          "week_id": "2030.01"
        },
        {
          "chore_type_id": "ct-c",
          "done": true,
          "user_id": "user-1",
          "week_id": "2030.01"
        },
        {
          "chore_type_id": "ct-c",
          "done": true,
          "user_id": "user-2",
          "week_id": "2030.01"
        }
      ]
      """

    Examples: user_id = <user_id>
      | user_id |
      | user-1  |
      | user-2  |


  Scenario: Validate update of field completed_at when completing a chore
    Given there is 1 user, 1 chore type and weekly chores for the week "2022.01"
    And the fields
      | field         | value   |
      | week_id       | 2022.01 |
      | chore_type_id | ct-a    |
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "204"
    And the Api response is empty
    When I send a request to the Api resource "listChores"
    Then the response status code is "200"
    And the response field ".[0].completed_at" is different than "[NULL]"


  Scenario Outline: Validate error response when requesting other user's data
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the header language is set to "<lang>"
    And the fields
      | field         | value   |
      | week_id       | 2022.01 |
      | chore_type_id | ct-a    |
    And I use the token of the user with id "user-2"
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                               |
      | en       | You are not assigned to any chores of type ct-a for week 2022.01      |
      | es       | No estás asignado a ninguna tarea de tipo ct-a para la semana 2022.01 |
      | whatever | You are not assigned to any chores of type ct-a for week 2022.01      |


  Scenario Outline: Validate error response when completing a task twice
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the header language is set to "<lang>"
    And the fields
      | field         | value   |
      | week_id       | 2022.01 |
      | chore_type_id | ct-a    |
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "204"
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "<err_msg>"

    Examples: lang = <lang>
      | lang     | err_msg                                                                |
      | en       | Chore with week_id=2022.01 and chore_type_id=ct-a is already completed |
      | es       | La tarea de la semana 2022.01 y tipo ct-a está ya completada           |
      | whatever | Chore with week_id=2022.01 and chore_type_id=ct-a is already completed |


  Scenario Outline: Validate error response invalid week_id
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the fields
      | field         | value     | as_string |
      | week_id       | <week_id> | True      |
      | chore_type_id | ct-a      | False     |
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "422"
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
