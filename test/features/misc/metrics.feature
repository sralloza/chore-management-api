@metrics
@old
Feature: Prometheus metrics

  As an admin
  I want to monitor the deployment with Prometheus metrics


  Scenario: Calls to /metrics should not be registered in metrics
    Given I send a request to the Api resource "metrics"
    Then the response status code is "200"
    And the metric counter "http_request_duration_seconds" added has not changed


  Scenario: Calls to /health should not be registered in metrics
    When I send a request to the Api resource "health"
    Then the response status code is "200"
    And the metric counter "http_request_duration_seconds" added has not changed


  Scenario Outline: Different status codes should be registered in metrics
    When I send a request to the Api resource "<resource>"
    Then the response status code is "<status_code>"
    And the metric counter "http_request_duration_seconds" added has been incremented by 1

    Examples: resource = <resource> | status_code = <status_code>
      | resource         | status_code |
      | notFound         | 404         |
      | notFoundGet      | 404         |
      | notFoundPost     | 404         |
      | notFoundPut      | 404         |
      | notFoundDelete   | 404         |
      | notFoundPatch    | 404         |
      | getCurrentWeekId | 200         |
      | getLastWeekId    | 200         |
      | getNextWeekId    | 200         |
      | createFlat       | 422         |
      | listFlats        | 401         |


  Scenario Outline: Calls to <operation> should be grouped in metrics ignoring the flat id
    Given the field "<parameter>" with string value "xxx"
    When I send a request to the Api resource "<operation>"
    And the field "<parameter>" with string value "yyy"
    When I send a request to the Api resource "<operation>"
    Then the metric counter "http_request_duration_seconds" with labels has been incremented by 2
      | label  | value    |
      | method | <method> |
      | path   | <url>    |

    Examples:
      | operation        | parameter     | method | url                                 |
      | getFlat          | flat_name     | GET    | /api/v1/flats/{flat_name}           |
      | deleteFlat       | flat_name     | DELETE | /api/v1/flats/{flat_name}           |
      | editFlatSettings | flat_name     | PATCH  | /api/v1/flats/{flat_name}/settings  |
      | getChoreType     | chore_type_id | GET    | /api/v1/chore-types/{chore_type_id} |
      | deleteChoreType  | chore_type_id | DELETE | /api/v1/chore-types/{chore_type_id} |
      | getUser          | user_id       | GET    | /api/v1/users/{user_id}             |
      | deleteUser       | user_id       | DELETE | /api/v1/users/{user_id}             |


  Scenario: Increment metric when a flat is created
    Given I request a flat create code
    And I use a random API key
    When I send a request to the Api resource "createFlat" with body params
      | param_name  | param_value           |
      | create_code | [CONTEXT:create_code] |
      | name        | test-flat             |
    Then the response status code is "200"
    And the metric counter "flats_created" has been incremented by 1
