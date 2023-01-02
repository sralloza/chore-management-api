@api.weekly-chores
@listWeeklyChores
Feature: Weekly Chores API - listWeeklyChores

  As an admin or user
  I want to list all weekly chores

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
  Scenario: Validate response for admin user
    Given I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario: List weekly chores
    Given there is 1 user
    And there is 1 chore type
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2022.01 |
      | 2022.02 |
      | 2022.03 |
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema
    And the Api response contains the expected data


  Scenario Outline: List missing weekly chores
    Given there are 2 users
    And there are 2 chore types
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2022.01 |
      | 2022.02 |
      | 2022.03 |
    And I use the admin API key
    And the fields
      | field         | value   |
      | chore_type_id | ct-a    |
      | week_id       | 2022.01 |
    When I send a request to the Api resource "completeChore"
    And the fields
      | field         | value   |
      | chore_type_id | ct-b    |
      | week_id       | 2022.01 |
    When I send a request to the Api resource "completeChore"
    Then the response status code is "204"
    And the fields
      | field         | value   |
      | chore_type_id | ct-a    |
      | week_id       | 2022.02 |
    When I send a request to the Api resource "completeChore"
    Then the response status code is "204"
    Given I use the token of the user with id "user-1"
    And the parameters to filter the request
      | param_name   | param_value    |
      | missing_only | <missing_only> |
      | page         | <page>         |
      | per_page     | <per_page>     |
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      <expected_json>
      """

    Examples: missing_only = <missing_only> | page = <page> | per_page = <per_page> | expected_json = <expected_json>
      | missing_only | page   | per_page | expected_json                     |
      | [TRUE]       | [NONE] | [NONE]   | listWeeklyChoresMissingOnlyTrue   |
      | [FALSE]      | [NONE] | [NONE]   | listWeeklyChoresMissingOnlyFalse  |
      | [NONE]       | 1      | 1        | listWeeklyChoresOnlyPerPage1Page1 |
      | [NONE]       | 2      | 1        | listWeeklyChoresOnlyPerPage1Page2 |
      | [NONE]       | 3      | 1        | listWeeklyChoresOnlyPerPage1Page3 |


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
