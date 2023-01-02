@api.transfers
@startTransfer
Feature: Transfers API - startTransfer

  As an admin or user
  I want to transfer a chore from one user to another


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
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And I use the token of the user with id "user-1"
    When I send a request to the Api with body params
      | param_name    | param_value |
      | user_id_from  | user-1      |
      | user_id_to    | user-2      |
      | chore_type_id | ct-a        |
      | week_id       | 2022.01     |
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And I use the token of the user with id "user-1"
    When I send a request to the Api with body params
      | param_name    | param_value |
      | user_id_from  | user-1      |
      | user_id_to    | user-2      |
      | chore_type_id | ct-a        |
      | week_id       | 2022.01     |
    Then the response status code is "200"
    And the response status code is defined


  Scenario Outline: Validate error response when using keyword me with the admin token
    Given there is 1 user
    And the header language is set to "<lang>"
    And I use the admin API key
    When I send a request to the Api with body params
      | param_name    | param_value |
      | user_id_from  | me          |
      | user_id_to    | user-2      |
      | chore_type_id | ct-a        |
      | week_id       | 2022.01     |
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                                            |
      | en       | Can't use the special keyword me with the admin API key                            |
      | es       | No se puede usar la palabra clave especial me con la clave de API de administrador |
      | whatever | Can't use the special keyword me with the admin API key                            |


  Scenario Outline: Validate error response when requesting other user's data
    Given there are 2 users
    And the header language is set to "<lang>"
    And I use the token of the user with id "user-2"
    When I send a request to the Api with body params
      | param_name    | param_value |
      | user_id_from  | user-1      |
      | user_id_to    | user-2      |
      | chore_type_id | ct-a        |
      | week_id       | 2022.01     |
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                             |
      | en       | You cannot create a transfer for another user       |
      | es       | No puedes crear una transferencia para otro usuario |
      | whatever | You cannot create a transfer for another user       |


  Scenario Outline: Start chore transfer happy path
    Given there are 3 users, 3 chore types and weekly chores for the week "2022.01"
    And I use the token of the user with id "<real_user_id>"
    When I send a request to the Api with body params
      | param_name    | param_value | as_string |
      | user_id_from  | <user_id>   | false     |
      | user_id_to    | user-2      | false     |
      | chore_type_id | ct-a        | false     |
      | week_id       | 2022.01     | true      |
    Then the response status code is "200"
    And the database contains the following transfers
      | user_id_from     | user_id_to | chore_type_id | week_id | completed | accepted |
      | <simple_user_id> | 2          | ct-a          | 2022.01 | False     | None     |
    And the database contains the following weekly chores
      | week_id | A                | B | C |
      | 2022.01 | <simple_user_id> | 2 | 3 |
    And the database contains the following tickets
      | user_id | A | B | C |
      | user-1  | 0 | 0 | 0 |
      | user-2  | 0 | 0 | 0 |
      | user-3  | 0 | 0 | 0 |

    Examples: user_id = <user_id> | real_user_id = <real_user_id>
      | user_id | real_user_id | simple_user_id |
      | me      | user-1       | 1              |
      | user-1  | user-1       | 1              |


  Scenario: Start multiple chore transfers
    Given there are 5 users
    And there are 5 chore types
    And I create the weekly chores for the week "2022.01" using the API
    And I use the token of the user with id "user-1"
    When I send a request to the Api with body params
      | param_name    | param_value |
      | user_id_from  | user-1      |
      | user_id_to    | user-2      |
      | chore_type_id | ct-a        |
      | week_id       | 2022.01     |
    Then the response status code is "200"
    And I use the token of the user with id "user-3"
    When I send a request to the Api with body params
      | param_name    | param_value |
      | user_id_from  | user-3      |
      | user_id_to    | user-1      |
      | chore_type_id | ct-c        |
      | week_id       | 2022.01     |
    Then the response status code is "200"
    And I use the token of the user with id "user-5"
    When I send a request to the Api with body params
      | param_name    | param_value |
      | user_id_from  | user-5      |
      | user_id_to    | user-4      |
      | chore_type_id | ct-e        |
      | week_id       | 2022.01     |
    Then the response status code is "200"
    And the database contains the following transfers
      | user_id_from | user_id_to | chore_type_id | week_id | completed | accepted |
      | 1            | 2          | ct-a          | 2022.01 | False     | None     |
      | 3            | 1          | ct-c          | 2022.01 | False     | None     |
      | 5            | 4          | ct-e          | 2022.01 | False     | None     |
    And the database contains the following weekly chores
      | week_id | A | B | C | D | E |
      | 2022.01 | 1 | 2 | 3 | 4 | 5 |
    And the database contains the following tickets
      | user_id | A | B | C | D | E |
      | user-1  | 0 | 0 | 0 | 0 | 0 |
      | user-2  | 0 | 0 | 0 | 0 | 0 |
      | user-3  | 0 | 0 | 0 | 0 | 0 |
      | user-4  | 0 | 0 | 0 | 0 | 0 |
      | user-5  | 0 | 0 | 0 | 0 | 0 |


  Scenario: Start chore transfer to user-2 after user-1 has rejected it.
    Given there are 3 users, 3 chore types and weekly chores for the week "2022.01"
    And I use the token of the user with id "user-1"
    When I send a request to the Api with body params
      | param_name    | param_value |
      | user_id_from  | user-1      |
      | user_id_to    | user-2      |
      | chore_type_id | ct-a        |
      | week_id       | 2022.01     |
    Then the response status code is "200"
    Given I save the "id" attribute of the response as "transfer_id"
    And I use the token of the user with id "user-2"
    When I send a request to the Api resource "rejectTransfer"
    Then the response status code is "200"
    Given I use the token of the user with id "user-1"
    When I send a request to the Api with body params
      | param_name    | param_value |
      | user_id_from  | user-1      |
      | user_id_to    | user-3      |
      | chore_type_id | ct-a        |
      | week_id       | 2022.01     |
    Then the response status code is "200"
    And the response contains the following transfers
      | user_id_from | user_id_to | chore_type_id | week_id | completed | accepted |
      | 1            | 3          | ct-a          | 2022.01 | False     | None     |
    And the database contains the following transfers
      | user_id_from | user_id_to | chore_type_id | week_id | completed | accepted |
      | 1            | 2          | ct-a          | 2022.01 | True      | False    |
      | 1            | 3          | ct-a          | 2022.01 | False     | None     |


  Scenario: Admin makes a chore transfer
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And I use the admin API key
    When I send a request to the Api with body params
      | param_name    | param_value |
      | user_id_from  | user-1      |
      | user_id_to    | user-2      |
      | chore_type_id | ct-a        |
      | week_id       | 2022.01     |
    Then the response status code is "200"
    And the database contains the following transfers
      | user_id_from | user_id_to | chore_type_id | week_id | completed | accepted |
      | 1            | 2          | ct-a          | 2022.01 | False     | None     |
    And the database contains the following weekly chores
      | week_id | A | B |
      | 2022.01 | 1 | 2 |
    And the database contains the following tickets
      | user_id | A | B |
      | user-1  | 0 | 0 |
      | user-2  | 0 | 0 |


  Scenario Outline: Validate error response when the payload is not a valid json
    Given the header language is set to "<lang>"
    When I send a request to the Api with body
      """
      xxx
      """
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                       |
      | en       | Request body is not a valid JSON              |
      | es       | El cuerpo de la petición no es un JSON válido |
      | whatever | Request body is not a valid JSON              |


  Scenario Outline: Validate error response when a user tries to transfer a chore to multiple users
    Given there are 3 users, 3 chore types and weekly chores for the week "2022.01"
    And the header language is set to "<lang>"
    And I use the token of the user with id "user-1"
    When I send a request to the Api with body params
      | param_name    | param_value |
      | user_id_from  | user-1      |
      | user_id_to    | user-2      |
      | chore_type_id | ct-a        |
      | week_id       | 2022.01     |
    Then the response status code is "200"
    When I send a request to the Api with body params
      | param_name    | param_value | as_string |
      | user_id_from  | user-1      | false     |
      | user_id_to    | user-3      | false     |
      | chore_type_id | ct-a        | false     |
      | week_id       | 2022.01     | true      |
    Then the response status code is "400"
    And the error message is "<err_msg>"

    Examples:
      | lang     | err_msg                                               |
      | en       | Cannot transfer chore to multiple users               |
      | es       | No se puede transferir una tarea a múltiples usuarios |
      | whatever | Cannot transfer chore to multiple users               |


  Scenario Outline: Validate error response with invalid params
    Given there is 1 user
    And I use the admin API key
    When I send a request to the Api with body params
      | param_name    | param_value     | as_string |
      | user_id_from  | <user_id_from>  | false     |
      | user_id_to    | <user_id_to>    | false     |
      | chore_type_id | <chore_type_id> | false     |
      | week_id       | <week_id>       | true      |
    Then the response status code is "422"
    And the response status code is defined
    And the response contains the following validation errors
      | location | param   | msg       |
      | body     | <param> | <err_msg> |

    Examples: user_id_from = <user_id_from> | user_id_to = <user_id_to> | chore_type_id = <chore_type_id> | week_id = <week_id> | param = <param> | err_msg = <err_msg>
      | user_id_from | user_id_to | chore_type_id | week_id | param         | err_msg                      |
      | [NULL]       | user-2     | ct-a          | 2022.01 | user_id_from  | none is not an allowed value |
      | user-1       | [NULL]     | ct-a          | 2022.01 | user_id_to    | none is not an allowed value |
      | user-1       | user-2     | [NULL]        | 2022.01 | chore_type_id | none is not an allowed value |
      | user-1       | user-2     | ct-a          | [NULL]  | week_id       | none is not an allowed value |


  Scenario Outline: Validate multiweek syntax support
    Given there are 2 users, 2 chore types and weekly chores for the week "<real_week_id>"
    And I use the admin API key
    When I send a request to the Api with body params
      | param_name    | param_value | as_string |
      | user_id_from  | user-1      | false     |
      | user_id_to    | user-2      | false     |
      | chore_type_id | ct-a        | false     |
      | week_id       | <week_id>   | true      |
    Then the response status code is "200"
    And the response attribute "week_id" as string is "<real_week_id>"

    Examples: week_id = <week_id> | real_week_id = <real_week_id>
      | week_id | real_week_id          |
      | next    | [NOW(%Y.%W) + 7 DAYS] |
      | current | [NOW(%Y.%W)]          |
      | last    | [NOW(%Y.%W) - 7 DAYS] |


  Scenario Outline: Validate error response when the user_id does not belong to any user
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And the header language is set to "<lang>"
    And I use the admin API key
    When I send a request to the Api with body params
      | param_name    | param_value    | as_string |
      | user_id_from  | <user_id_from> | false     |
      | user_id_to    | <user_id_to>   | false     |
      | chore_type_id | ct-a           | false     |
      | week_id       | 2022.01        | true      |
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: user_id_from = <user_id_from> | user_id_to = <user_id_to>
      | user_id_from | user_id_to | lang     | err_msg                                 |
      | invalid      | user-1     | en       | User with id=invalid does not exist     |
      | invalid      | user-1     | es       | No existe ningún usuario con id=invalid |
      | invalid      | user-1     | whatever | User with id=invalid does not exist     |
      | user-1       | invalid    | en       | User with id=invalid does not exist     |
      | user-1       | invalid    | es       | No existe ningún usuario con id=invalid |
      | user-1       | invalid    | whatever | User with id=invalid does not exist     |


  Scenario Outline: Validate error response when the user_id_from is the same as the user_id_to
    Given I use the admin API key
    And the header language is set to "<lang>"
    When I send a request to the Api with body params
      | param_name    | param_value | as_string |
      | user_id_from  | user-1      | false     |
      | user_id_to    | user-1      | false     |
      | chore_type_id | ct-a        | false     |
      | week_id       | 2022.01     | true      |
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                           |
      | en       | Cannot transfer chore to the same user            |
      | es       | No se puede transferir una tarea al mismo usuario |
      | whatever | Cannot transfer chore to the same user            |


  Scenario Outline: Validate error response when a user tries to transfer a chore that belongs to another user
    Given there are 3 users, 3 chore types and weekly chores for the week "2022.01"
    And I use the token of the user with id "user-1"
    And the header language is set to "<lang>"
    When I send a request to the Api with body params
      | param_name    | param_value | as_string |
      | user_id_from  | user-1      | false     |
      | user_id_to    | user-2      | false     |
      | chore_type_id | ct-c        | false     |
      | week_id       | 2022.01     | true      |
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                                              |
      | en       | No chores of type ct-c for week 2022.01 assigned to user with id=user-1              |
      | es       | No hay tareas de tipo ct-c para la semana 2022.01 asignadas al usuario con id=user-1 |
      | whatever | No chores of type ct-c for week 2022.01 assigned to user with id=user-1              |


  Scenario Outline: Validate error response when a user tries to transfer a chore which type does not exist
    Given there are 3 users
    And the header language is set to "<lang>"
    And I use the admin API key
    When I send a request to the Api with body params
      | param_name    | param_value | as_string |
      | user_id_from  | user-1      | false     |
      | user_id_to    | user-2      | false     |
      | chore_type_id | X           | false     |
      | week_id       | 2022.01     | true      |
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                 |
      | en       | ChoreType with id=X does not exist      |
      | es       | No existe ningún tipo de tarea con id=X |
      | whatever | ChoreType with id=X does not exist      |


  Scenario Outline: Validate error response with invalid week_id
    Given there are 2 users, 2 chore types and weekly chores for the week "2022.01"
    And I use the admin API key
    When I send a request to the Api with body params
      | param_name    | param_value | as_string |
      | user_id_from  | user-1      | false     |
      | user_id_to    | user-2      | false     |
      | chore_type_id | ct-a        | false     |
      | week_id       | <week_id>   | true      |
    Then the response status code is "422"
    And the response status code is defined
    And the response contains the following validation errors
      | location | param   | msg                                                          |
      | body     | week_id | string does not match regex "[CONF:patterns.weekIdExtended]" |

    Examples: week_id = <week_id>
      | week_id      |
      | invalid-week |
      | 2022-03      |
      | 2022.3       |
      | 2022.00      |
      | 2022.55      |
      | 2022023      |
      | whatever     |


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
