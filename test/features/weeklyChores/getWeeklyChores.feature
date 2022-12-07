@api.weekly-chores
@getWeeklyChores
Feature: Weekly Chores API - getWeeklyChores

  As an admin or user
  I want to get the detils of the weekly chores given a specific week


  @authorization
  Scenario: Validate response for guest
    When I send a request to the Api
    Then the response status code is "401"
    And the error message is "Missing API key"


  @authorization
  Scenario: Validate response for user
    Given there is 1 user, 1 chore type and weekly chores for the week "2022.01"
    And the field "week_id" with string value "2022.01"
    And I use the token of the user with id "user-1"
    When I send a request to the Api
    Then the response status code is "200"


  @authorization
  Scenario: Validate response for admin
    Given there is 1 user, 1 chore type and weekly chores for the week "2022.01"
    And the field "week_id" with string value "2022.01"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"


  Scenario Outline: Get weekly chores by week_id
    Given there is 1 user, 1 chore type and weekly chores for the week "<real_week_id>"
    And I use the token of the user with id "user-1"
    And the field "week_id" with string value "<week_id>"
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the response contains the following weekly chores
      | week_id        | A |
      | <real_week_id> | 1 |

    Examples: week_id = <week_id> | real_week_id = <real_week_id>
      | week_id | real_week_id          |
      | next    | [NOW(%Y.%W) + 7 DAYS] |
      | current | [NOW(%Y.%W)]          |
      | last    | [NOW(%Y.%W) - 7 DAYS] |


  Scenario: Validate error response when weekly chores not found
    Given I use the admin API key
    And the field "week_id" with value "2022.01"
    When I send a request to the Api
    Then the response status code is "404"
    And the error message is "No weekly chores found for week 2022.01"


  Scenario Outline: Validate error response when trying to get weekly chores by an invalid week_id
    Given the field "week_id" with string value "<week_id>"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "422"
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
