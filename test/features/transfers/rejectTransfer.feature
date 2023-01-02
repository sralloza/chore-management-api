@api.transfers
@rejectTransfer
Feature: Transfers API - rejectTransfer

  As an admin or user
  I want to reject a chore transfer other user sent me


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
    And the field "transfer_id" with value "1"
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


  Scenario Outline: Validate error response when requesting other user's data
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the header language is set to "<lang>"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | None     |
    And I save the "id" attribute of the response as "transfer_id"
    Given I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                |
      | en       | You cannot reject a transfer for another user          |
      | es       | No puedes rechazar una transferencia para otro usuario |
      | whatever | You cannot reject a transfer for another user          |


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


  Scenario Outline: Validate error response when rejecting a chore transfer twice
    Given there are 3 users
    And there are 3 chore types
    And I create the weekly chores for the week "2022.01" using the API
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | None     |
    And I save the "id" attribute of the response as "transfer_id"
    And I use the token of the user with id "user-2"
    And the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "200"
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message contains "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                             |
      | en       | Transfer is already completed       |
      | es       | La transferencia ya está completada |
      | whatever | Transfer is already completed       |


  Scenario Outline: Validate error response when rejecting a chore transfer with invalid transfer_id
    Given I use the admin API key
    And the field "transfer_id" with value "999"
    And the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
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


  @common
  Scenario: Validate X-Correlator creation
    Given I don't include the X-Correlator header in the request
    When I send a request to the Api
    Then the X-Correlator is present in the response
