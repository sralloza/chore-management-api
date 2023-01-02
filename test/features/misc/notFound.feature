@notFound
Feature: notFound

  As a non authenticated user
  I want to receive a 404 if I send a request to a non existing route


  Scenario Outline: Validate 404 generic response
    When I send a request to the Api resource "<resource>"
    Then the response status code is "404"
    And the error message is "Not Found"

    Examples: resource = <resource>
      | resource       |
      | notFound       |
      | notFoundGet    |
      | notFoundPost   |
      | notFoundPut    |
      | notFoundDelete |
      | notFoundPatch  |


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
