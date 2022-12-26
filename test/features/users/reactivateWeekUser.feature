@api.users
@reactivateWeekUser
Feature: Users API - reactivateWeekUser

  As an admin or user
  I want to add a user or myself to the weekly chores assigments after removing it


  @authorization
  Scenario: Validate response for guest
    When I send a request to the Api
    Then the response status code is "401"
    And the error message is "Missing API key"


  @authorization
  Scenario: Validate response for user
    Given there is 1 user
    And I deactivate the chore creation for the week "2025.01" and user "user-1"
    And the fields
      | field   | value   |
      | user_id | user-1  |
      | week_id | 2025.01 |
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "200"


  @authorization
  Scenario: Validate response for admin
    Given there is 1 user
    And I deactivate the chore creation for the week "2025.01" and user "user-1"
    And the fields
      | field   | value   |
      | user_id | user-1  |
      | week_id | 2025.01 |
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"


  Scenario Outline: A user reactivates user creation for a single week
    Given there are 3 users
    And there are 3 chore types
    And I deactivate the chore creation for the week "2025.01" and user "<real_user_id>"
    And the field "tenantId" with value "<user_id>"
    And I use the token of the user with id "<real_user_id>"
    And the field "week_id" with value "2025.01"
    When I send a request to the Api
    Then the response status code is "200"
    Given I create the weekly chores for the week "2025.01" using the API
    Then the database contains the following weekly chores
      | week_id | A | B | C |
      | 2025.01 | 1 | 2 | 3 |

    Examples: user_id = <user_id> | real_user_id = <real_user_id>
      | user_id | real_user_id |
      | user-2  | user-2       |
      | me      | user-2       |


  Scenario Outline: Validate multiweek syntax support
    Given there are 3 users
    And there are 3 chore types
    And I deactivate the chore creation for the week "<real_week_id>" and user "user-2"
    And the fields
      | field     | value     | as_string |
      | tenant_id | user-2    | false     |
      | week_id   | <week_id> | true      |
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    Given I create the weekly chores for the week "<real_week_id>" using the API
    And the database contains the following weekly chores
      | week_id        | A | B | C |
      | <real_week_id> | 1 | 2 | 3 |

    Examples: week_id = <week_id> | real_week_id = <real_week_id>
      | week_id | real_week_id          |
      | 2025.01 | 2025.01               |
      | next    | [NOW(%Y.%W) + 7 DAYS] |
      | current | [NOW(%Y.%W)]          |
      | last    | [NOW(%Y.%W) - 7 DAYS] |


  Scenario Outline: Validate error response when reactivated user creation for an invalid week
    Given there is 1 user, 1 chore type and weekly chores for the week "2022.05"
    And I deactivate the chore creation for the week "2022.05" and user "user-1" editing the database
    And I use the admin API key
    And the fields
      | field   | value     |
      | user_id | user-1    |
      | week_id | <week_id> |
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "<msg>"

    Examples: week_id = <week_id> | msg = <msg>
      | week_id | msg                                  |
      | 2022.05 | Chore types exist for week 2022.05   |
      | 2022.01 | Chore types exist after week 2022.01 |


  Scenario: Validate error response when using keyword me with the admin token
    Given there is 1 user
    And I use the admin API key
    And the fields
      | field   | value   |
      | user_id | me      |
      | week_id | 2022.01 |
    When I send a request to the Api
    Then the response status code is "400"
    And the error message is "Can't use the special keyword me with the admin API key"


  Scenario: Validate error response when requesting other user's data
    Given there are 2 users
    And I use the token of the user with id "user-1"
    And the fields
      | field   | value   |
      | user_id | user-2  |
      | week_id | 2022.01 |
    When I send a request to the Api
    Then the response status code is "403"
    And the error message is "You don't have permission to access this user's data"


  Scenario: Validate error response when reactivating chore creation for a non skipped week
    Given there is 1 user
    And the fields
      | field   | value   |
      | user_id | user-1  |
      | week_id | 2025.01 |
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "409"
    And the error message is "Week 2025.01 is already activated for user user-1"


  Scenario Outline: Validate error response when reactivating chore creation for a syntactically invalid week
    Given there is 1 user
    And the fields
      | field   | value     | as_string |
      | user_id | user-1    | false     |
      | week_id | <week_id> | true      |
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "422"
    And the response status code is defined
    And the response contains the following validation errors
      | location | param   | msg                                                          |
      | path     | week_id | string does not match regex "[CONF:patterns.weekIdExtended]" |

    Examples: week_id = <week_id>
      | week_id      |
      | invalid-week |
      | 2022-03      |
      | 2022.3       |
      | 2022.00      |
      | 2022.55      |
      | 2022023      |
      | whatever     |
