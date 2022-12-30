@skip
@api.users
@deleteUser
Feature: Users API - deleteUser

  As an admin
  I want to delete a user

  @authorization
  Scenario: Validate response for guest user
    When I send a request to the Api
    Then the response status code is "403"
    And the error message is "Admin access required"


  @authorization
  Scenario: Validate response for user user
    Given I create a user and I use the user API key
    When I send a request to the Api
    Then the response status code is "403"
    And the error message is "Admin access required"


  @authorization
  Scenario: Validate response for admin user
    Given there is 1 user
    And the field "user_id" with value "1"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "204"


  Scenario: Delete user
    Given I use the admin API key
    When I send a request to the Api resource "createuser" with body params
      | param_name | param_value |
      | username   | John        |
      | user_id    | 111         |
    And I clear the token
    Then the response status code is "200"
    Given the field "user_id" with value "111"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "204"
    And the Api response is empty
    When I send a request to the Api resource "listusers"
    Then the response status code is "200"
    And the Api response contains the expected data
      """
      []
      """


  Scenario: Validate error response deleting a non-existing user
    Given the field "user_id" with value "111"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "404"
    And the error message is "No user found with id 111"


  Scenario: Validate error response deleting a user with open tasks
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And I create the weekly chores for the week "2022.02" using the API
    Given the field "user_id" with value "1"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "user has 2 pending chores"


  Scenario: Validate error response deleting a user with negative tickets
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type | week_id | accepted |
      | 1            | 2          | A          | 2022.01 | True     |
    Given the field "user_id" with value "1"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "user has unbalanced tickets"


  Scenario: Validate error response deleting a user with positive tickets
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type | week_id | accepted |
      | 1            | 2          | A          | 2022.01 | True     |
    Given the field "user_id" with value "2"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "user has unbalanced tickets"


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
