@api.users
@getUser
Feature: Users API - getUser

  As an admin, user
  I want to access a user's data or I want to access myself's data


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
    And the field "user_id" saved as "created_user_id"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given I create a user
    And the field "user_id" saved as "created_user_id"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario Outline: Get user by id with the user API key
    Given I create a user and I use the user API key
    And the field "user_id" with value "<user_id>"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema
    And the Api response contains the expected data

    Examples: user_id = <user_id>
      | user_id                   |
      | [CONTEXT:created_user_id] |
      | me                        |


  Scenario Outline: Validate error response when using keyword me with the admin API key
    Given I use the admin API key
    And the header language is set to "<lang>"
    And the field "user_id" with value "me"
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                                            |
      | en       | Can't use the special keyword me with the admin API key                            |
      | es       | No se puede usar la palabra clave especial me con la clave de API de administrador |
      | whatever | Can't use the special keyword me with the admin API key                            |


  Scenario Outline: Validate error response when requesting other user's data
    Given I create a user
    And the field "user_id" with value "user-1"
    And the header language is set to "<lang>"
    And I use the user API key
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                                    |
      | en       | You don't have permission to access this user's data       |
      | es       | No tienes permiso para acceder a los datos de este usuario |
      | whatever | You don't have permission to access this user's data       |


  Scenario Outline: Validate error response when requesting a non existing user
    Given I use the admin API key
    And the field "user_id" with value "xxx"
    And the header language is set to "<lang>"
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                             |
      | en       | User with id=xxx does not exist     |
      | es       | No existe ningún usuario con id=xxx |
      | whatever | User with id=xxx does not exist     |


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
