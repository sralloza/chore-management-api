@api.chore-types
@deleteChoreType
Feature: Chore Types API - deleteChoreType

  As an admin
  I want to delete a specific chore type


  @authorization
  Scenario: Validate response for guest user
    When I send a request to the Api
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "Missing API key"


  @authorization
  Scenario: Validate response for user
    Given there is 1 chore type
    And I create a user and I use the user API key
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "Admin access required"


  @authorization
  Scenario: Validate response for admin user
    Given there is 1 chore type
    And I use the admin API key
    And the field "chore_type_id" with value "ct-a"
    When I send a request to the Api
    Then the response status code is "204"
    And the response status code is defined


  Scenario: Delete chore type
    Given there is 1 chore type
    And I use the admin API key
    And the field "chore_type_id" with value "ct-a"
    When I send a request to the Api
    Then the response status code is "204"
    And the Api response is empty
    When I send a request to the Api resource "listChoreTypes"
    Then the response status code is "200"
    And the Api response contains the expected data
      """
      []
      """


  Scenario: Ensure tickets are also deleted
    Given there is 1 user
    And there is 1 chore type
    And the field "chore_type_id" with value "ct-a"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "204"
    And the Api response is empty
    And the database contains the following tickets


  Scenario: Ensure chores are also deleted
    Given there is 1 user, 1 chore type and weekly chores for the week "2022.01"
    And the user "user-1" has completed the chore "ct-a" for the week "2022.01"
    And the field "chore_type_id" with value "ct-a"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "204"
    And the Api response is empty
    Given the parameters to filter the request
      | param_name    | param_value |
      | chore_type_id | ct-a        |
    When I send a request to the Api resource "listChores"
    Then the response status code is "200"
    And the Api response contains the expected data
      """
      []
      """


  Scenario: Validate error response when deleting a non existing chore type
    Given the field "chore_type_id" with value "invalid"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "ChoreType with id=invalid does not exist"


  Scenario: Validate error response when deleting a chore type with pending chores
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And I create the weekly chores for the week "2022.02" using the API
    And the field "chore_type_id" with value "ct-a"
    Given I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Can't delete chore type with active chores"


  Scenario: Validate error response when deleting a chore type with non balanced tickets
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | True     |
    And the user "user-2" has completed the chore "ct-a" for the week "2022.01"
    And the field "chore_type_id" with value "ct-a"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Chore type has unbalanced tickets"


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
