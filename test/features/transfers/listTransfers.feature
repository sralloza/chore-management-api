@api.transfers
@listTransfers
Feature: Transfers API - listTransfers

  As a admin or user
  I want to list the chore transfers

  @authorization
  Scenario: Validate response for guest user
    When I send a request to the Api
    Then the response status code is "401"
    And the error message is "Missing API key"


  @authorization
  Scenario: Validate response for user user
    Given I create a user and I use the user API key
    When I send a request to the Api
    Then the response status code is "200"


  @authorization
  Scenario: Validate response for admin user
    Given there is 1 user
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"


  Scenario: List transfers when database is not empty
    Given there are 4 users, 4 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | True     |
      | user-3       | user-2     | ct-c          | 2022.01 | False    |
      | user-4       | user-2     | ct-d          | 2022.01 | None     |
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "200"
    # And the response body is validated against the json-schema
    And the Api response contains the expected data
      | skip_param   |
      | id           |
      | created_at   |
      | completed_at |


  Scenario: List transfers when database is empty
    Given there is 1 user
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      []
      """
