@api.tickets
@listTickets
Feature: Tickets API - listTickets

  As an admin, flat admin or user
  I want to list the tickets


  @authorization
  Scenario: Validate response for unauthorized user
    Given I use a random API key
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "User access required"
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
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for flat admin
    Given I create a flat with a user and I use the flat API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given I create a flat
    And the "[CONTEXT:created_flat_name]" as X-Flat header
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario: List tickets with only one user and one chore type
    Given I create a flat with a user
    When I send a request to the Api resource "createChoreType" with body params
      | param_name  | param_value     |
      | id          | test-chore-type |
      | name        | Test chore type |
      | description | whatever        |
    Then the response status code is "200"
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      [
        {
          "id": "test-chore-type",
          "name": "Test chore type",
          "description": "whatever",
          "tickets_by_user_id": {
            "[CONTEXT:created_user_id]": 0
          },
          "tickets_by_user_name": {
            "[CONTEXT:created_user_username]": 0
          }
        }
      ]
      """

  Scenario: List tickets with only three users and three chore types
    Given I create a flat
    And there are 3 chore types
    And there are 3 users
    And I use the flat API key
    When I send a request to the Api
    Then the response status code is "200"
    Then the response status code is defined
    And the response body is validated against the json-schema
    And the Api response contains the expected data


  Scenario: List tickets when there are no chore types
    Given I create a flat with a user and I use the flat API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      []
      """


  Scenario: List tickets when there are no users
    Given I create a flat
    And there are 2 chore types
    And I use the flat API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      [
        {
          "id": "ct-a",
          "name": "ct-a",
          "description": "description1",
          "tickets_by_user_id": {},
          "tickets_by_user_name": {}
        },
        {
          "id": "ct-b",
          "name": "ct-b",
          "description": "description2",
          "tickets_by_user_id": {},
          "tickets_by_user_name": {}
        }
      ]
      """


  Scenario: Validate error response when using the admin API key without the X-Flat header
    Given I create a flat
    And I use the admin API key
    When I send a request to the Api with body params
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Must use the X-Flat header with the admin API key"
    And the response error message is defined


  Scenario: Validate error response when using the X-Flat header without the admin API key
    Given I create a flat with a user and I use the flat API key
    And the "xxx" as X-Flat header
    When I send a request to the Api with body params
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Can't use the X-Flat header without the admin API key"
    And the response error message is defined


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
