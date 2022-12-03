@api.weekly-chores
@createWeeklyChores
Feature: Weekly Chores API - createWeeklyChores

  As an admin
  I want to create the weekly chores

  @authorization
  Scenario: Validate response for guest
    When I send a request to the Api
    Then the response status code is "401"
    And the error message is "Missing API key"


  @authorization
  Scenario: Validate response for user
    Given I create a user and I use the user API key
    When I send a request to the Api
    Then the response status code is "403"
    And the error message is "Admin access required"


  @authorization
  Scenario: Validate response for admin user
    Given there is 1 user
    And there is 1 chore type
    And the field "week_id" with string value "2022.01"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"


  Scenario: Create weekly chores when same number of users and chore types (postive rotation)
    Given there are 4 users
    And there are 4 chore types
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2022.01 |
      | 2022.02 |
      | 2022.03 |
      | 2022.04 |
      | 2022.15 |
      | 2022.16 |
      | 2022.17 |
      | 2022.18 |
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | ct-a   | ct-b   | ct-c   | ct-d   |
      | 2022.01 | user-1 | user-2 | user-3 | user-4 |
      | 2022.02 | user-2 | user-3 | user-4 | user-1 |
      | 2022.03 | user-3 | user-4 | user-1 | user-2 |
      | 2022.04 | user-4 | user-1 | user-2 | user-3 |
      | 2022.15 | user-1 | user-2 | user-3 | user-4 |
      | 2022.16 | user-2 | user-3 | user-4 | user-1 |
      | 2022.17 | user-3 | user-4 | user-1 | user-2 |
      | 2022.18 | user-4 | user-1 | user-2 | user-3 |


  Scenario: Create weekly chores when same number of users and chore types (negative rotation)
    Given there are 4 users
    And there are 4 chore types
    And I use the admin API key
    When I send a request to the Api resource "editSystemSettings" with body params
      | param_name    | param_value |
      | rotation_sign | negative    |
    Then the response status code is "200"
    Given I create the weekly chores for the following weeks using the API
      | week_id |
      | 2022.01 |
      | 2022.02 |
      | 2022.03 |
      | 2022.04 |
      | 2022.15 |
      | 2022.16 |
      | 2022.17 |
      | 2022.18 |
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | ct-a   | ct-b   | ct-c   | ct-d   |
      | 2022.01 | user-1 | user-2 | user-3 | user-4 |
      | 2022.02 | user-4 | user-1 | user-2 | user-3 |
      | 2022.03 | user-3 | user-4 | user-1 | user-2 |
      | 2022.04 | user-2 | user-3 | user-4 | user-1 |
      | 2022.15 | user-1 | user-2 | user-3 | user-4 |
      | 2022.16 | user-4 | user-1 | user-2 | user-3 |
      | 2022.17 | user-3 | user-4 | user-1 | user-2 |
      | 2022.18 | user-2 | user-3 | user-4 | user-1 |


  Scenario: Create weekly chores when there are more users than chore types
    Given there are 5 users
    And there are 3 chore types
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2022.01 |
      | 2022.02 |
      | 2022.03 |
      | 2022.04 |
      | 2022.15 |
      | 2022.16 |
      | 2022.17 |
      | 2022.18 |
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | ct-a   | ct-b   | ct-c   |
      | 2022.01 | user-1 | user-2 | user-3 |
      | 2022.02 | user-2 | user-3 | user-4 |
      | 2022.03 | user-3 | user-4 | user-5 |
      | 2022.04 | user-4 | user-5 | user-1 |
      | 2022.15 | user-5 | user-1 | user-2 |
      | 2022.16 | user-1 | user-2 | user-3 |
      | 2022.17 | user-2 | user-3 | user-4 |
      | 2022.18 | user-3 | user-4 | user-5 |


  Scenario: Create weekly chores when there are more chore types than users
    Given there are 3 users
    And there are 5 chore types
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2022.01 |
      | 2022.02 |
      | 2022.03 |
      | 2022.04 |
      | 2022.15 |
      | 2022.16 |
      | 2022.17 |
      | 2022.18 |
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | ct-a   | ct-b   | ct-c   | ct-d   | ct-e   |
      | 2022.01 | user-1 | user-2 | user-3 | user-1 | user-2 |
      | 2022.02 | user-2 | user-3 | user-1 | user-2 | user-3 |
      | 2022.03 | user-3 | user-1 | user-2 | user-3 | user-1 |
      | 2022.04 | user-1 | user-2 | user-3 | user-1 | user-2 |
      | 2022.15 | user-2 | user-3 | user-1 | user-2 | user-3 |
      | 2022.16 | user-3 | user-1 | user-2 | user-3 | user-1 |
      | 2022.17 | user-1 | user-2 | user-3 | user-1 | user-2 |
      | 2022.18 | user-2 | user-3 | user-1 | user-2 | user-3 |


  @skip
  Scenario: Create weekly chores when a tenant skips a week
    Given there are 4 users
    And there are 4 chore types
    And the tenant "2" skips the week "2025.15"
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2025.01 |
      | 2025.02 |
      | 2025.03 |
      | 2025.04 |
      | 2025.15 |
      | 2025.16 |
      | 2025.17 |
      | 2025.18 |
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B     | C | D |
      | 2025.01 | 1 | 2     | 3 | 4 |
      | 2025.02 | 2 | 3     | 4 | 1 |
      | 2025.03 | 3 | 4     | 1 | 2 |
      | 2025.04 | 4 | 1     | 2 | 3 |
      | 2025.15 | 1 | 1,3,4 | 3 | 4 |
      | 2025.16 | 2 | 3     | 4 | 1 |
      | 2025.17 | 3 | 4     | 1 | 2 |
      | 2025.18 | 4 | 1     | 2 | 3 |


  @skip
  Scenario: Create weekly chores when two users skips a couple of weeks
    Given there are 4 users
    And there are 4 chore types
    And the tenant "2" skips the week "2025.15"
    And the tenant "3" skips the week "2025.15"
    And the tenant "3" skips the week "2025.16"
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2025.01 |
      | 2025.02 |
      | 2025.03 |
      | 2025.04 |
      | 2025.15 |
      | 2025.16 |
      | 2025.17 |
      | 2025.18 |
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B     | C   | D |
      | 2025.01 | 1 | 2     | 3   | 4 |
      | 2025.02 | 2 | 3     | 4   | 1 |
      | 2025.03 | 3 | 4     | 1   | 2 |
      | 2025.04 | 4 | 1     | 2   | 3 |
      | 2025.15 | 1 | 1,4   | 1,4 | 4 |
      | 2025.16 | 2 | 1,2,4 | 4   | 1 |
      | 2025.17 | 3 | 4     | 1   | 2 |
      | 2025.18 | 4 | 1     | 2   | 3 |


  @skip
  Scenario: Create weekly chores when all users but one skip a week
    Given there are 4 users
    And there are 4 chore types
    And the tenant "1" skips the week "2025.15"
    And the tenant "2" skips the week "2025.15"
    And the tenant "4" skips the week "2025.15"
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2025.01 |
      | 2025.02 |
      | 2025.03 |
      | 2025.04 |
      | 2025.15 |
      | 2025.16 |
      | 2025.17 |
      | 2025.18 |
    And I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B | C | D |
      | 2025.01 | 1 | 2 | 3 | 4 |
      | 2025.02 | 2 | 3 | 4 | 1 |
      | 2025.03 | 3 | 4 | 1 | 2 |
      | 2025.04 | 4 | 1 | 2 | 3 |
      | 2025.15 | 3 | 3 | 3 | 3 |
      | 2025.16 | 1 | 2 | 3 | 4 |
      | 2025.17 | 2 | 3 | 4 | 1 |
      | 2025.18 | 3 | 4 | 1 | 2 |


  Scenario Outline: Validate multiweek syntax support
    Given there are 4 users
    And there are 4 chore types
    And the field "week_id" with string value "<week_id>"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id        | ct-a   | ct-b   | ct-c   | ct-d   |
      | <real_week_id> | user-1 | user-2 | user-3 | user-4 |

    Examples:
      | week_id | real_week_id          |
      | next    | [NOW(%Y.%W) + 7 DAYS] |
      | current | [NOW(%Y.%W)]          |
      | last    | [NOW(%Y.%W) - 7 DAYS] |


  Scenario: Validate error response when creating duplicate weekly chores
    Given there is 1 user
    And there is 1 chore type
    And the field "week_id" with string value "2022.01"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    When I send a request to the Api
    Then the response status code is "409"
    And the error message contains "Weekly chores for week .+ already exist"


  Scenario Outline: Validate error response when creating weekly chores for invalid week
    Given the field "week_id" with string value "<invalid_week_id>"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "422"
    And the response contains the following validation errors
      | location | param   | msg                                                          |
      | path     | week_id | string does not match regex "[CONF:patterns.weekIdExtended]" |

    Examples: invalid_week_id = <invalid_week_id>
      | invalid_week_id |
      | invalid-week    |
      | 2022-03         |
      | 2022.3          |
      | 2022.00         |
      | 2022.55         |
      | 2022023         |
      | whatever        |


  @skip
  Scenario Outline: Validate error response when creating weekly chores for an old week
    Given there are 1 tenant, 1 chore type and weekly chores for the week "[NOW(%Y.%W)]"
    And the field "weekId" with string value "<old_week_id>"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "Invalid week ID (too old): <old_week_id>"

    Examples: old_week_id = <old_week_id>
      | old_week_id           |
      | 2022.09               |
      | 2022.04               |
      | 2021.04               |
      | 2020.44               |
      | [NOW(%Y.%W) - 7 DAYS] |


  Scenario: Validate error response when creating weekly chores after users have changed
    Given there are 3 users
    And there are 3 chore types
    And I create the weekly chores for the week "2022.01" using the API
    And I use the admin API key
    When I send a request to the Api resource "createTenant" with body params
      | param_name | param_value |
      | username   | John        |
      | tenant_id  | 111         |
    Then the response status code is "200"
    Given the field "weekId" with string value "2022.02"
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is the following
      """
      users have changed since weekly chore creation. Use force parameter to restart the weekly chores creation.
      """


  Scenario: Create weekly tasks if a tenant is created and deleted
    Given there are 3 users
    And there are 3 chore types
    And I create the weekly chores for the week "2022.01" using the API
    And I use the admin API key
    When I send a request to the Api resource "createTenant" with body params
      | param_name | param_value |
      | username   | John        |
      | tenant_id  | 111         |
    Then the response status code is "200"
    Given the field "tenantId" with value "111"
    When I send a request to the Api resource "deleteTenant"
    Then the response status code is "204"
    Given the field "weekId" with string value "2022.02"
    When I send a request to the Api
    Then the response status code is "200"
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B | C |
      | 2022.01 | 1 | 2 | 3 |
      | 2022.02 | 2 | 3 | 1 |


  Scenario: Restart weekly tasks creation if new tenant is registered using weekID endpoint
    Given there are 3 users
    And there are 5 chore types
    And I create the weekly chores for the following weeks using the API
      | week_id |
      | 2022.01 |
      | 2022.02 |
    And I use the admin API key
    When I send a request to the Api resource "createTenant" with body params
      | param_name | param_value |
      | username   | tenant4     |
      | tenant_id  | 4           |
    Then the response status code is "200"
    Given the field "weekId" with string value "2022.03"
    And the parameters to filter the request
      | param_name | param_value |
      | force      | true        |
    When I send a request to the Api
    Then the response status code is "200"
    Given I use the admin API key
    When I send a request to the Api resource "listWeeklyChores"
    Then the response status code is "200"
    And the response contains the following weekly chores
      | week_id | A | B | C | D | E |
      | 2022.01 | 1 | 2 | 3 | 1 | 2 |
      | 2022.02 | 2 | 3 | 1 | 2 | 3 |
      | 2022.03 | 1 | 2 | 3 | 4 | 1 |

  Scenario: Validate error response when creating weekly chores but there are no users
    Given there is 1 chore type
    And the field "weekId" with string value "2022.01"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "Can't create weekly chores, no users registered"


  Scenario: Validate error response when creating weekly chores but there are no chore types
    Given there is 1 tenant
    And the field "weekId" with string value "2022.01"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "Can't create weekly chores, no chore types registered"
