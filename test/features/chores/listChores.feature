@api.chores
@listChores
Feature: Chores API - listChores

  As an admin or user
  I want to list the ungrouped chores


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
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario: List simple chores when no chores are created
    Given I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the Api response contains the expected data
      """
      []
      """


  Scenario: List simple chores when database is not empty
    Given there are 4 users, 4 chore types and weekly chores for the week "2030.01"
    And the fields
      | field         | value   |
      | week_id       | 2030.01 |
      | chore_type_id | ct-a    |
    And I use the token of the user with id "user-1"
    When I send a request to the Api resource "completeChore"
    Then the response status code is "204"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    # Issue with pydantic
    # app/models/chore.py:11
    # And the response body is validated against the json-schema
    And the Api response contains the expected data
      | skip_param   |
      | created_at   |
      | completed_at |
      | id           |


  Scenario Outline: Validate filters
    Given there are 4 users
    And there are 4 chore types
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2030.01 |
      | 2030.02 |
    And the fields
      | field         | value   |
      | week_id       | 2030.01 |
      | chore_type_id | ct-a    |
    And I use the token of the user with id "user-1"
    When I send a request to the Api resource "completeChore"
    Then the response status code is "204"
    Given the parameters to filter the request
      | param_name    | param_value     |
      | chore_type_id | <chore_type_id> |
      | user_id       | <user_id>       |
      | week_id       | <week_id>       |
      | done          | <done>          |
      | page          | <page>          |
      | per_page      | <per_page>      |
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the response contains the chores "<result>"

    Examples: chore_type_id = <chore_type_id> | user_id = <user_id> | week_id = <week_id> | done = <done> | page = <page> | per_page = <per_page> | result = <result>
      | chore_type_id | user_id | week_id | done    | page   | per_page | result          |
      | [NULL]        | [NULL]  | [NULL]  | [NULL]  | [NONE] | [NONE]   | 1,2,3,4,5,6,7,8 |
      | [NULL]        | [NULL]  | [NULL]  | [NULL]  | [NONE] | 4        | 1,2,3,4         |
      | [NULL]        | [NULL]  | [NULL]  | [NULL]  | 2      | 4        | 5,6,7,8         |
      | [NULL]        | [NULL]  | [NULL]  | [NULL]  | 2      | 7        | 8               |
      | ct-a          | [NULL]  | [NULL]  | [NULL]  | [NONE] | [NONE]   | 1,5             |
      | [NULL]        | user-1  | [NULL]  | [NULL]  | [NONE] | [NONE]   | 1,8             |
      | [NULL]        | me      | [NULL]  | [NULL]  | [NONE] | [NONE]   | 1,8             |
      | [NULL]        | [NULL]  | 2030.01 | [NULL]  | [NONE] | [NONE]   | 1,2,3,4         |
      | [NULL]        | [NULL]  | 2030.02 | [NULL]  | [NONE] | [NONE]   | 5,6,7,8         |
      | [NULL]        | [NULL]  | [NULL]  | [TRUE]  | [NONE] | [NONE]   | 1               |
      | [NULL]        | [NULL]  | [NULL]  | [FALSE] | [NONE] | [NONE]   | 2,3,4,5,6,7,8   |
      | ct-a          | user-1  | [NULL]  | [NULL]  | [NONE] | [NONE]   | 1               |
      | ct-a          | me      | [NULL]  | [NULL]  | [NONE] | [NONE]   | 1               |
      | [NULL]        | [NULL]  | 2030.01 | [TRUE]  | [NONE] | [NONE]   | 1               |
      | [NULL]        | [NULL]  | 2030.01 | [FALSE] | [NONE] | [NONE]   | 2,3,4           |
      | [NULL]        | [NULL]  | 2030.02 | [TRUE]  | [NONE] | [NONE]   | [EMPTY]         |
      | [NULL]        | user-1  | [NULL]  | [FALSE] | [NONE] | [NONE]   | 8               |
      | [NULL]        | me      | [NULL]  | [FALSE] | [NONE] | [NONE]   | 8               |
      | [NULL]        | user-1  | [NULL]  | [TRUE]  | [NONE] | [NONE]   | 1               |
      | [NULL]        | me      | [NULL]  | [TRUE]  | [NONE] | [NONE]   | 1               |
      | ct-b          | [NULL]  | [NULL]  | [FALSE] | [NONE] | [NONE]   | 2,6             |



  Scenario Outline: Validate multiweek syntax
    Given there are 2 users, 2 chore types and weekly chores for the week "<real_week_id>"
    And the fields
      | field         | value          |
      | week_id       | <real_week_id> |
      | chore_type_id | ct-a           |
    And I use the token of the user with id "user-1"
    When I send a request to the Api resource "completeChore"
    Then the response status code is "204"
    Given the parameters to filter the request
      | param_name | param_value |
      | week_id    | <week_id>   |
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the Api response contains the expected data
      | skip_param   |
      | id           |
      | created_at   |
      | completed_at |
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


  Scenario Outline: Validate error response when using keyword me with the admin token
    Given there is 1 user
    And I use the admin API key
    And the header language is set to "<lang>"
    And the parameters to filter the request
      | param_name | param_value |
      | user_id    | me          |
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                                            |
      | en       | Can't use the special keyword me with the admin API key                            |
      | es       | No se puede usar la palabra clave especial me con la clave de API de administrador |
      | whatever | Can't use the special keyword me with the admin API key                            |


  Scenario Outline: Validate error response when filtering by an invalid week_id
    Given the parameters to filter the request
      | param_name | param_value |
      | week_id    | <week_id>   |
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "422"
    And the response contains the following validation errors
      | location | param   | msg                                                          |
      | query    | week_id | string does not match regex "[CONF:patterns.weekIdExtended]" |

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
