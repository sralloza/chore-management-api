@health
Feature: health

  As a non authenticated user
  I want to check the health of the application


  Scenario: Check application health
    When I send a request to the Api
    Then the response status code is "200"
    And the Api response contains the expected data


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


  Scenario: Validate X-Powered-By disabled
    When I send a request to the Api
    Then the header "X-Powered-By" is not present in the response
