@api.week-id
@getCurrentWeekId
Feature: Week ID API - getCurrentWeekId

  As a non authenticated user
  I want to get the current week id


  @authorization
  Scenario: Validate response for unauthorized user
    Given I use a random API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for guest
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for user
    Given I create a user and I use the user API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario: Get current week ID
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema
    And the response attribute "week_id" as string is "[NOW(%Y.%W)]"


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
