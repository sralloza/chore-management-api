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
    Given I send a request to the Api resource "health"
    Then the response status code is "200"
    And the metric "http_request_duration_seconds_count" has not changed

  # Scenario: Generic 404 errors should be registered in metrics
  # Scenario: Different status codes should be registered in metrics
