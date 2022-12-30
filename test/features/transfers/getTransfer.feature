@api.transfers
@getTransfer
Feature: Transfers API - getTransfer

  As an admin or user
  I want to get the details of a specific transfer


  @authorization
  Scenario Outline: Validate response for unauthorized user
    Given I use a random API key
    And the header language is set to "<lang>"
    And the field "transfer_id" with value "1"
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
    Given the field "transfer_id" with value "1"
    And the header language is set to "<lang>"
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
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | None     |
    Then the response status code is "200"
    And I save the "id" attribute of the response as "transfer_id"
    Given I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "200"


  @authorization
  Scenario: Validate response for admin user
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | None     |
    Then the response status code is "200"
    And I save the "id" attribute of the response as "transfer_id"
    Given I use the token of the user with id "user-2"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"


  Scenario: Get transfer happy path
    Given there are 3 users, 3 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted | id_attr_name |
      | user-1       | user-2     | ct-a          | 2022.01 | None     | transfer_id  |
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "200"
    # And the response body is validated against the json-schema
    And the response contains the following transfers
      | user_id_from | user_id_to | chore_type_id | week_id | completed | accepted |
      | 1            | 2          | ct-a          | 2022.01 | False     | None     |


  Scenario Outline: Validate error response when transfer does not exist
    Given I use the admin API key
    And the header language is set to "<lang>"
    And the field "transfer_id" with value "999"
    When I send a request to the Api
    Then the response status code is "404"
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                    |
      | en       | Transfer with id=999 does not exist        |
      | es       | No existe ninguna transferencia con id=999 |
      | whatever | Transfer with id=999 does not exist        |


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
