@api.flats
@deleteFlat
Feature: Flats API - deleteFlat

  As an admin
  I want to delete a flat


  @authorization
  Scenario: Validate response for unauthorized user
    Given I use a random API key
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "Admin access required"
    And the response error message is defined


  @authorization
  Scenario: Validate response for guest
    Given I create a flat
    And the field "flat_name" saved as "created_flat_name"
    When I send a request to the Api
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "Missing API key"
    And the response error message is defined


  @authorization
  Scenario: Validate response for user
    Given I create a flat with a user and I use the user API key
    And the field "flat_name" saved as "created_flat_name"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "Admin access required"
    And the response error message is defined


  @authorization
  Scenario: Validate response for flat admin
    Given I create a flat and I use the flat API key
    And the field "flat_name" saved as "created_flat_name"
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "Admin access required"
    And the response error message is defined


  @authorization
  Scenario: Validate response for admin
    Given I create a flat
    And the field "flat_name" saved as "created_flat_name"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "204"
    And the response status code is defined


  Scenario: Delete flat
    Given I create a flat
    And the field "flat_name" saved as "created_flat_name"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "204"
    And the Api response is empty
    When I send a request to the Api resource "listFlats"
    And the Api response contains the expected data
      """
      []
      """


  Scenario: Validate error response when flat does not exist
    Given I use the admin API key
    And the field "flat_name" with value "whatever"
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "Flat not found: whatever"
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
