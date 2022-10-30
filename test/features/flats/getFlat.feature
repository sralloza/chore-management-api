@api.flats
@getFlat
Feature: Flats API - getFlat

  As an admin
  I want to get the details of a specific flat


  @authorization
  Scenario: Validate response for guest
    Given the field "flat_name" with value "test-flat"
    When I send a request to the Api
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "Missing API key"


  @authorization
  Scenario: Validate response for user
    Given I create a flat with a user and I use the user API key
    And the field "flat_name" with value "test-flat"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "Admin access required"


  @authorization
  Scenario: Validate response for flat owner
    Given I create a flat and I use the flat API key
    And the field "flat_name" with value "test-flat"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "Admin access required"


  @authorization
  Scenario: Validate response for admin
    Given I create a flat
    And the field "flat_name" saved as "created_flat_name"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario: Get flat when it exists
    Given I create a flat
    And the field "flat_name" saved as "created_flat_name"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data


  Scenario: Validate error response when the flat doesn't exist
    Given the field "flat_name" with value "invalid_flat"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "Flat not found: invalid_flat"
    And the response error message is defined


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
