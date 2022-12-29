@api.transfers
@rejectTransfer
Feature: Transfers API - rejectTransfer

  As an admin or user
  I want to reject a chore transfer other user sent me


  @authorization
  Scenario: Validate response for guest
    Given the field "transfer_id" with value "1"
    When I send a request to the Api
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "Missing API key"


  @authorization
  Scenario: Validate response for user
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | None     |
    Then the response status code is "200"
    And I save the "id" attribute of the response as "transfer_id"
    Given I use the token of the user with id "user-2"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | None     |
    Then the response status code is "200"
    And I save the "id" attribute of the response as "transfer_id"
    Given I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario: Validate error response when requesting other user's data
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | None     |
    And I save the "id" attribute of the response as "transfer_id"
    Given I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "You cannot reject a transfer for another user"


  Scenario: Reject chore transfer happy path
    Given there are 3 users, 3 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | None     |
    And I save the "id" attribute of the response as "transfer_id"
    And I use the token of the user with id "user-2"
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the database contains the following transfers
      | user_id_from | user_id_to | chore_type_id | week_id | completed | accepted |
      | 1            | 2          | ct-a          | 2022.01 | True      | False    |
    And the database contains the following weekly chores
      | week_id | A | B | C |
      | 2022.01 | 1 | 2 | 3 |
    And the database contains the following tickets
      | user_id | A | B | C |
      | user-1  | 0 | 0 | 0 |
      | user-2  | 0 | 0 | 0 |
      | user-3  | 0 | 0 | 0 |


  Scenario: Validate error response when rejecting a chore transfer twice
    Given there are 3 users
    And there are 3 chore types
    And I create the weekly chores for the week "2022.01" using the API
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | None     |
    And I save the "id" attribute of the response as "transfer_id"
    And I use the token of the user with id "user-2"
    When I send a request to the Api
    Then the response status code is "200"
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message contains "Transfer is already completed"


  Scenario: Validate error response when rejecting a chore transfer with invalid transfer_id
    Given I use the admin API key
    And the field "transfer_id" with value "999"
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "Transfer with id=999 does not exist"
