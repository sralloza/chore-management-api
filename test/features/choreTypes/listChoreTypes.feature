@api.chore-type
@listChoreTypes
@old
Feature: Chore Types API - listChoreTypes

  As an admin, flat admin or user
  I want to list the defined chore types


  @authorization
  Scenario: Validate response for unauthorized user
    Given I use a random API key
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "User access required"
    And the response error message is defined


  @authorization
  Scenario: Validate response for guest
    When I send a request to the Api
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "Missing API key"
    And the response error message is defined


  @authorization
  Scenario: Validate response for user
    Given I create a flat with a user and I use the user API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for flat admin
    Given I create a flat with a user and I use the flat API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given I create a flat
    And the "[CONTEXT:created_flat_name]" as X-Flat header
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"


  Scenario: List chore types when empty
    Given I create a flat and I use the flat API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response body is validated against the json-schema
    And the Api response contains the expected data
      """
      []
      """


  Scenario: List chore types when non empty
    Given I create a flat
    Given there are 4 chore types
    And I use the flat API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema
    And the Api response contains the expected data


  Scenario: Validate error response when using the X-Flat header without the admin API key
    Given I create a flat and I use the flat API key
    And the "xxx" as X-Flat header
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Can't use the X-Flat header without the admin API key"
    And the response error message is defined


  Scenario: Validate error response when using the admin API key without the X-Flat header
    Given I use the admin API key
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Must use the X-Flat header with the admin API key"
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
