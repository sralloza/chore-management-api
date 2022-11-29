@api.users
@createUser
Feature: Users API - createUser

  As an admin
  I want to register a new user


  @authorization
  Scenario: Validate response for unauthorized user
    Given I use a random API key
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "Admin access required"


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
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "Admin access required"


  @authorization
  Scenario: Validate response for admin
    Given I use the admin API key
    When I send a request to the Api with body params
      | param_name | param_value |
      | username   | John        |
      | id         | john123     |
    Then the response status code is "200"
    And the response status code is defined


  Scenario Outline: Create a new user
    Given I use the admin API key
    When I send a request to the Api with body params
      | param_name | param_value |
      | username   | <username>  |
      | id         | <id>        |
    Then the response status code is "200"
    And the response status code is defined
    And the Api response contains the expected data
      | skip_param |
      | api_key    |
      """
      {
        "username": "<username>",
        "id": "<id>"
      }
      """

    Examples:
      | username                | id                      |
      | John                    | john123                 |
      | [STRING_WITH_LENGTH_25] | john123                 |
      | [STRING_WITH_LENGTH_2]  | john123                 |
      | John                    | [STRING_WITH_LENGTH_40] |
      | John                    | [STRING_WITH_LENGTH_4]  |
      | 1111                    | 1111                    |


  Scenario: Validate that the assignment_order setting of the flat is reset after creating a user
    Given I use the admin API key
    And there are 3 users
    And I use the admin API key
    When I send a request to the Api resource "editSystemSettings" with body params
      | param_name         | param_value |
      | assignment_order.0 | user-2      |
      | assignment_order.1 | user-3      |
      | assignment_order.2 | user-1      |
      | rotation_sign      | negative    |
    Then the response status code is "200"
    When I send a request to the Api with body params
      | param_name | param_value |
      | username   | user-0      |
      | id         | user-0      |
    Then the response status code is "200"
    When I send a request to the Api resource "getSystemSettings"
    Then the response status code is "200"
    And the Api response contains the expected data
      | skip_param |
      | api_key    |
      """
      {
        "assignment_order": [
          "user-1",
          "user-2",
          "user-3",
          "user-0"
        ],
        "rotation_sign": "negative"
      }
      """


  Scenario: Validate error response creating a duplicate user
    Given I use the admin API key
    When I send a request to the Api with body params
      | param_name | param_value |
      | username   | John        |
      | id         | 11111       |
    Then the response status code is "200"
    When I send a request to the Api with body params
      | param_name | param_value |
      | username   | John        |
      | id         | 11111       |
    Then the response status code is "409"
    And the response status code is defined
    And the error message is "User with id=11111 already exists"


  Scenario: Validate error response creating a user with invalid body
    Given I use the admin API key
    When I send a request to the Api with body
      """
      whatever
      """
    Then the response status code is "400"
    And the response status code is defined
    And the error message contains "Request body is not a valid JSON"


  Scenario Outline: Validate error response when sending invalid data
    Given I use the admin API key
    When I send a request to the Api with body params
      | param_name | param_value |
      | username   | <username>  |
      | id         | <id>        |
    Then the response status code is "422"
    And the response status code is defined
    And the response contains the following validation errors
      | location | param   | msg   |
      | body     | <param> | <msg> |

    Examples: username = <username> | id = <id> | param = <param> | msg = <msg>
      | username                | id                      | param    | msg                                         |
      | x                       | user-id                 | username | ensure this value has at least 2 characters |
      | [STRING_WITH_LENGTH_26] | user-id                 | username | ensure this value has at most 25 characters |
      | xx                      | xxx                     | id       | ensure this value has at least 4 characters |
      | xx                      | [STRING_WITH_LENGTH_41] | id       | ensure this value has at most 40 characters |
      | xx                      | me                      | id       | Forbidden user ID: me                       |
      | xx                      | Me                      | id       | Forbidden user ID: me                       |
      | xx                      | mE                      | id       | Forbidden user ID: me                       |
      | xx                      | ME                      | id       | Forbidden user ID: me                       |


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
