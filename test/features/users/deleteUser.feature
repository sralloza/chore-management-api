@api.users
@deleteUser
Feature: Users API - deleteUser

  As an admin
  I want to delete a user


  @authorization
  Scenario Outline: Validate response for unauthorized user
    Given I use a random API key
    And the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                           |
      | en       | Admin access required             |
      | es       | Acceso de administrador requerido |
      | whatever | Admin access required             |


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
  Scenario Outline: Validate response for user
    Given I create a user and I use the user API key
    And the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                           |
      | en       | Admin access required             |
      | es       | Acceso de administrador requerido |
      | whatever | Admin access required             |


  @authorization
  Scenario: Validate response for admin
    Given there is 1 user
    And the field "user_id" with value "user-1"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "204"


  Scenario: Delete user
    Given I use the admin API key
    When I send a request to the Api resource "createUser" with body params
      | param_name | param_value |
      | username   | John        |
      | id         | john-id     |
    And I clear the token
    Then the response status code is "200"
    Given the field "user_id" with value "john-id"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "204"
    And the Api response is empty
    When I send a request to the Api resource "listUsers"
    Then the response status code is "200"
    And the Api response contains the expected data
      """
      []
      """


  Scenario: Ensure chores are also deleted
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the user "user-1" has completed the chore "ct-a" for the week "2022.01"
    And the field "user_id" with value "user-1"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "204"
    Given the parameters to filter the request
      | param_name | param_value |
      | user_id    | user-1      |
    When I send a request to the Api resource "listChores"
    Then the response status code is "200"
    And the Api response contains the expected data
      """
      []
      """


  Scenario Outline: Validate error response deleting a non-existing user
    Given the field "user_id" with value "111"
    And the header language is set to "<lang>"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "404"
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                             |
      | en       | User with id=111 does not exist     |
      | es       | No existe ningún usuario con id=111 |
      | whatever | User with id=111 does not exist     |


  Scenario Outline: Validate error response deleting a user with open tasks
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And I create the weekly chores for the week "2022.02" using the API
    And the field "user_id" with value "user-1"
    And the header language is set to "<lang>"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                            |
      | en       | Can't delete a user with active chores             |
      | es       | No se puede eliminar un usuario con tareas activas |
      | whatever | Can't delete a user with active chores             |


  Scenario Outline: Validate error response deleting a user with negative tickets
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | True     |
    And the field "user_id" with value "user-1"
    And the header language is set to "<lang>"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                 |
      | en       | Can't delete a user with unbalanced tickets             |
      | es       | No se puede eliminar un usuario con tickets sin cuadrar |
      | whatever | Can't delete a user with unbalanced tickets             |


  Scenario Outline: Validate error response deleting a user with positive tickets
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the following transfers are created
      | user_id_from | user_id_to | chore_type_id | week_id | accepted |
      | user-1       | user-2     | ct-a          | 2022.01 | True     |
    And the user "user-2" has completed the chore "ct-a" for the week "2022.01"
    And the user "user-2" has completed the chore "ct-b" for the week "2022.01"
    And the field "user_id" with value "user-2"
    And the header language is set to "<lang>"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                 |
      | en       | Can't delete a user with unbalanced tickets             |
      | es       | No se puede eliminar un usuario con tickets sin cuadrar |
      | whatever | Can't delete a user with unbalanced tickets             |


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
