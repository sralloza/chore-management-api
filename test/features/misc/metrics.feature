@metrics
Feature: Prometheus metrics

  As an admin
  I want to monitor the deployment with Prometheus metrics


  Scenario: Calls to /metrics should not be registered in metrics
    Given I save the current metrics
    Given I send a request to the Api resource "metrics"
    Then the response status code is "200"
    And the metric "http_request_duration_seconds_count" has not changed


  Scenario: Calls to /health should not be registered in metrics
    Given I save the current metrics
    When I send a request to the Api resource "health"
    Then the response status code is "200"
    And the metric "http_request_duration_seconds_count" has not changed


  Scenario Outline: Different status codes should be registered in metrics
    Given I save the current metrics
    When I send a request to the Api resource "<resource>"
    Then the response status code is "<status_code>"
    And the metric "http_request_duration_seconds_count" has been incremented by 1

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
