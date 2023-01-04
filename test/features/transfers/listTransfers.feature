@api.transfers
@listTransfers
Feature: Transfers API - listTransfers

  As a admin or user
  I want to list the chore transfers


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


  Scenario: Validate pagination
    Given there are 4 users, 4 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | True     |
      | user-3       | user-2     | ct-c          | 2022.01 | False    |
      | user-4       | user-2     | ct-d          | 2022.01 | None     |
    And I use the token of the user with id "user-1"
    And the parameters to filter the request
      | param_name | param_value |
      | page       | 2           |
      | per_page   | 1           |
    When I send a request to the Api
    Then the response status code is "200"
    And the Api response contains the expected data
      | skip_param   |
      | id           |
      | created_at   |
      | completed_at |
      """
      [
        {
          "accepted": false,
          "chore_type_id": "ct-c",
          "completed": true,
          "user_id_from": "user-3",
          "user_id_to": "user-2",
          "week_id": "2022.01"
        }
      ]
      """

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


  @common
  Scenario: Validate X-Correlator creation
    Given I don't include the X-Correlator header in the request
    When I send a request to the Api
    Then the X-Correlator is present in the response
