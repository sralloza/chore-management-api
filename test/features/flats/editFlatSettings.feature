@api.flats
@editFlatSettings
Feature: Flats API - editFlatSettings

  As a flat admin
  I want to edit the flat's settings


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
    Given the field "flat_name" with value "xxx"
    When I send a request to the Api
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "Missing API key"
    And the response error message is defined


  @authorization
  Scenario: Validate response for user
    Given the field "flat_name" with value "xxx"
    And I create a flat with a user and I use the user API key
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "Flat administration access required"
    And the response error message is defined


  @authorization
  Scenario: Validate response for flat admin
    Given I create a flat and I use the flat API key
    And the field "flat_name" saved as "created_flat_name"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given I create a flat
    And the field "flat_name" saved as "created_flat_name"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario Outline: Edit flat settings when it exists
    Given I create a flat with a user and I use the flat API key
    And the field "flat_name" saved as "created_flat_name"
    When I send a request to the Api with body params
      | param_name         | param_value     |
      | assignment_order.0 | <user_id>       |
      | rotation_sign      | <rotation_sign> |
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      {
        "assignment_order": [
          "<user_id>"
        ],
        "rotation_sign": "<rotation_sign>"
      }
      """

    Examples: flat_name = <flat_name_param>, user_id = <user_id>, rotation_sign = <rotation_sign>
      | flat_name_param             | real_flat_name | user_id                   | rotation_sign |
      | [CONTEXT:created_flat_name] | test-flat      | [CONTEXT:created_user_id] | positive      |
      | [CONTEXT:created_flat_name] | test-flat      | [CONTEXT:created_user_id] | negative      |
      | me                          | test-flat      | [CONTEXT:created_user_id] | positive      |
      | me                          | test-flat      | [CONTEXT:created_user_id] | negative      |


  Scenario: Edit flat settings when it exists with 2 users
    Given I create a flat and I use the flat API key
    When I send a request to the Api resource "createUser" with body params
      | param_name | param_value |
      | username   | user-1      |
      | id         | user-1      |
    Then the response status code is "200"
    When I send a request to the Api resource "createUser" with body params
      | param_name | param_value |
      | username   | user-2      |
      | id         | user-2      |
    Then the response status code is "200"
    And the field "flat_name" saved as "created_flat_name"
    When I send a request to the Api with body params
      | param_name         | param_value |
      | assignment_order.0 | user-2      |
      | assignment_order.1 | user-1      |
      | rotation_sign      | negative    |
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      {
        "assignment_order": [
          "user-2",
          "user-1"
        ],
        "rotation_sign": "negative"
      }
      """


  Scenario: Validate error response when using the me keyword with the admin API key
    Given the field "flat_name" with value "me"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Can't use the me keyword with the admin API key"
    And the response error message is defined


  Scenario: Validate error response when the payload is not a valid json
    Given the field "flat_name" with value "xxx"
    When I send a request to the Api with body
      """
      xxx
      """
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Request body is not a valid JSON"
    And the response error message is defined


  Scenario: Validate error response when a flat admin tries to edit other flat settings
    Given I create a flat
    And I save the "api_key" attribute of the response as "first_flat_api_key"
    And I create a flat
    And the field "flat_name" saved as "created_flat_name"
    And the field "token" saved as "first_flat_api_key"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "You don't have permission to access this flat's information"
    And the response error message is defined


  Scenario: Validate error response when the flat doesn't exist
    Given the field "flat_name" with value "invalid_flat"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "Flat not found: invalid_flat"
    And the response error message is defined


  Scenario Outline: Validate error response when sending invalid data
    Given I create a flat with a user and I use the flat API key
    And the field "flat_name" saved as "created_flat_name"
    When I send a request to the Api with body params
      | param_name         | param_value     |
      | assignment_order   | [LIST:[]]       |
      | assignment_order.0 | <user_id>       |
      | rotation_sign      | <rotation_sign> |
    Then the response status code is "422"
    And the response status code is defined
    And the response contains the following validation errors
      | location | param   | msg   | value   |
      | body     | <param> | <msg> | <value> |
    And the response error message is defined


    Examples: user_id = <user_id>, rotation_sign = <rotation_sign>, param = <param>, msg = <msg>, value = <value>
      | user_id   | rotation_sign | param            | value           | msg                                                                |
      | [NONE]    | whatever      | rotation_sign    | whatever        | body.rotation_sign must be either 'positive' or 'negative'         |
      | [INT:123] | [NONE]        | assignment_order | [LIST:[123]]    | body.assignment_order contains invalid user ids or is missing some |
      | [NONE]    | [NONE]        | assignment_order | [LIST:[]]       | body.assignment_order contains invalid user ids or is missing some |
      | xxxx      | [NONE]        | assignment_order | [LIST:['xxxx']] | body.assignment_order contains invalid user ids or is missing some |


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
