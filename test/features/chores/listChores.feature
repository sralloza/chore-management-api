@api.chores
@listChores
Feature: Chores API - listChores

  As an admin or user
  I want to list the ungrouped chores


  @authorization
  Scenario: Validate response for unauthorized user
    Given I use a random API key
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "User access required"


  @authorization
  Scenario: Validate response for guest
    When I send a request to the Api
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "Missing API key"


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
      | skip_param |
      | created_at |
      | closed_at  |
      | id         |


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
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    # And the response body is validated against the json-schema
    And the response contains the chores "<result>"

    Examples: chore_type_id = <chore_type_id> | user_id = <user_id> | week_id = <week_id> | done = <done> | result = <result>
      | chore_type_id | user_id | week_id | done    | result          |
      | [NULL]        | [NULL]  | [NULL]  | [NULL]  | 1,2,3,4,5,6,7,8 |
      | ct-a          | [NULL]  | [NULL]  | [NULL]  | 1,5             |
      | [NULL]        | user-1  | [NULL]  | [NULL]  | 1,8             |
      | [NULL]        | me      | [NULL]  | [NULL]  | 1,8             |
      | [NULL]        | [NULL]  | 2030.01 | [NULL]  | 1,2,3,4         |
      | [NULL]        | [NULL]  | 2030.02 | [NULL]  | 5,6,7,8         |
      | [NULL]        | [NULL]  | [NULL]  | [TRUE]  | 1               |
      | [NULL]        | [NULL]  | [NULL]  | [FALSE] | 2,3,4,5,6,7,8   |
      | ct-a          | user-1  | [NULL]  | [NULL]  | 1               |
      | ct-a          | me      | [NULL]  | [NULL]  | 1               |
      | [NULL]        | [NULL]  | 2030.01 | [TRUE]  | 1               |
      | [NULL]        | [NULL]  | 2030.01 | [FALSE] | 2,3,4           |
      | [NULL]        | [NULL]  | 2030.02 | [TRUE]  | [EMPTY]         |
      | [NULL]        | user-1  | [NULL]  | [FALSE] | 8               |
      | [NULL]        | me      | [NULL]  | [FALSE] | 8               |
      | [NULL]        | user-1  | [NULL]  | [TRUE]  | 1               |
      | [NULL]        | me      | [NULL]  | [TRUE]  | 1               |
      | ct-b          | [NULL]  | [NULL]  | [FALSE] | 2,6             |


  Scenario: Validate error response when using keyword me with the admin token
    Given there is 1 user
    And I use the admin API key
    Given the parameters to filter the request
      | param_name | param_value |
      | user_id    | me          |
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Can't use the special keyword me with the admin API key"


  Scenario Outline: Validate error response when filtering by an invalid weekId
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
