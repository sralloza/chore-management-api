@api.users
@createUser
Feature: Users API - createUser

  As an admin or flat admin
  I want to register a new user


  @authorization
  Scenario: Validate response for unauthorized user
    Given I use a random API key
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "Flat administration access required"
    And the response error message is defined


  @authorization
  Scenario: Validate response for guest
    When I send a request to the Api
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "Missing API key"
    And the response error message is defined


  @authorization
  Scenario: Validate response for user
    Given I create a flat with a user and I use the user API key
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "Flat administration access required"
    And the response error message is defined


  @authorization
  Scenario: Validate response for flat admin
    Given I create a flat and I use the flat API key
    When I send a request to the Api with body params
      | param_name | param_value |
      | username   | John        |
      | id         | john123     |
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given I create a flat
    And I use the admin API key
    And the "[CONTEXT:created_flat_name]" as X-Flat header
    When I send a request to the Api with body params
      | param_name | param_value |
      | username   | John        |
      | id         | john123     |
    Then the response status code is "200"
    And the response status code is defined


  Scenario Outline: Create a new user
    Given I create a flat and I use the flat API key
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
    Given I create a flat and I use the flat API key
    And there are 3 users
    And I use the flat API key
    And the field "flat_name" saved as "created_flat_name"
    When I send a request to the Api resource "editFlatSettings" with body params
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
    When I send a request to the Api resource "getFlat"
    Then the response status code is "200"
    And the Api response contains the expected data
      | skip_param |
      | api_key    |
      """
      {
        "name": "[CONTEXT:created_flat_name]",
        "settings": {
          "assignment_order": [
            "user-0",
            "user-1",
            "user-2",
            "user-3"
          ],
          "rotation_sign": "negative"
        }
      }
      """


  Scenario: Validate error response creating a duplicate user
    Given I create a flat and I use the flat API key
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
    And the error message is "User already exists"
    And the response error message is defined


  Scenario: Validate error response when using the X-Flat header without the admin API key
    Given I create a flat and I use the flat API key
    And the "xxx" as X-Flat header
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Can't use the X-Flat header without the admin API key"
    And the response error message is defined


  Scenario: Validate error response when using the admin API key without the X-Flat header
    Given I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Must use the X-Flat header with the admin API key"
    And the response error message is defined


  Scenario: Validate error response creating a user with invalid body
    Given I create a flat and I use the flat API key
    When I send a request to the Api with body
      """
      whatever
      """
    Then the response status code is "400"
    And the response status code is defined
    And the error message contains "Request body is not a valid JSON"
    And the response error message is defined


  Scenario Outline: Validate error response when sending invalid data
    Given I create a flat and I use the flat API key
    When I send a request to the Api with body params
      | param_name | param_value |
      | username   | <username>  |
      | id         | <id>        |
    Then the response status code is "422"
    And the response status code is defined
    And the response contains the following validation errors
      | location | param   | msg   | value   |
      | body     | <param> | <msg> | <value> |
    And the response error message is defined

    Examples:
      | username                | id                      | param    | value                   | msg                                                    |
      | x                       | user-id                 | username | x                       | body.username must be between 2 and 25 characters long |
      | [STRING_WITH_LENGTH_26] | user-id                 | username | [STRING_WITH_LENGTH_26] | body.username must be between 2 and 25 characters long |
      | xx                      | xxx                     | id       | xxx                     | body.id must be between 4 and 40 characters long       |
      | xx                      | [STRING_WITH_LENGTH_41] | id       | [STRING_WITH_LENGTH_41] | body.id must be between 4 and 40 characters long       |
      | xx                      | me                      | id       | me                      | Forbidden user ID: me                                  |
      | xx                      | Me                      | id       | Me                      | Forbidden user ID: me                                  |
      | xx                      | mE                      | id       | mE                      | Forbidden user ID: me                                  |
      | xx                      | ME                      | id       | ME                      | Forbidden user ID: me                                  |


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


  Scenario: Validate X-Powered-By disabled
    When I send a request to the Api
    Then the header "X-Powered-By" is not present in the response
