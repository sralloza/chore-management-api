@api.tickets
@listTickets
Feature: Tickets API - listTickets

  As an admin or user
  I want to list the tickets


  @authorization
  Scenario Outline: Validate response for unauthorized user
    Given I use a random API key
    And the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                     |
      | en       | User access required        |
      | es       | Acceso de usuario requerido |
      | whatever | User access required        |


  @authorization
  Scenario Outline: Validate response for guest
    Given the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                  |
      | en       | Missing API key          |
      | es       | Falta la clave de la API |
      | whatever | Missing API key          |


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


  Scenario: List tickets with only one user and one chore type
    Given I use the admin API key
    When I send a request to the Api resource "createChoreType" with body params
      | param_name  | param_value     |
      | id          | test-chore-type |
      | name        | Test chore type |
      | description | whatever        |
    Then the response status code is "200"
    Given I create a user and I use the user API key
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
    Given there are 3 chore types
    And there are 3 users
    And I use the user API key
    When I send a request to the Api
    Then the response status code is "200"
    Then the response status code is defined
    And the response body is validated against the json-schema
    And the Api response contains the expected data


  Scenario: List tickets when there are no chore types
    Given I create a user and I use the user API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      []
      """


  Scenario: List tickets when there are no users
    Given there are 2 chore types
    And I use the admin API key
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
