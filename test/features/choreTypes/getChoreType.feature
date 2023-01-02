@api.chore-types
@getChoreType
Feature: Chore Types API - getChoreType

  As an admin or user
  I want to get the details of a chore type


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
    Given I create a user
    And there is 1 chore type
    And the field "chore_type_id" with value "ct-a"
    And I use the user API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given there is 1 chore type
    And the field "chore_type_id" with value "ct-a"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"


  Scenario: Get a chore type
    Given I create a user
    Given there is 1 chore type
    And the field "chore_type_id" with value "ct-a"
    And I use the user API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema
    And the Api response contains the expected data


  Scenario Outline: Validate error response when getting a non existing chore type
    Given I create a user
    And the header language is set to "<lang>"
    And the field "chore_type_id" with value "ct-a"
    And I use the user API key
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "<err_msg>"

    Examples: lang = <lang> | err_msg = <err_msg>
      | lang     | err_msg                                    |
      | en       | ChoreType with id=ct-a does not exist      |
      | es       | No existe ningún tipo de tarea con id=ct-a |
      | whatever | ChoreType with id=ct-a does not exist      |


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
