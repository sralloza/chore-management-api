@api.system
@getSystemSettings
Feature: System API - getSystemSettings

  As an admin
  I want to access the system's settings


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
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario Outline: Get system settings when there is 1 user
    Given I create a user
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data

    Examples: user_id = <user_id>, rotation_sign = <rotation_sign>
      | user_id                   | rotation_sign |
      | [CONTEXT:created_user_id] | positive      |
      | [CONTEXT:created_user_id] | negative      |
      | [CONTEXT:created_user_id] | positive      |
      | [CONTEXT:created_user_id] | negative      |


  Scenario: Get system settings when there are 2 users
    Given I use the admin API key
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
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      {
        "assignment_order": [
          "user-1",
          "user-2"
        ],
        "rotation_sign": "positive"
      }
      """


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
