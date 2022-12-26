@api.chore-types
@getChoreType
Feature: Chore Types API - getChoreType

  As an admin or user
  I want to get the details of a chore type


  @authorization
  Scenario: Validate response for unauthorized user
    Given I use a random API key
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "User access required"


  @authorization
  Scenario: Validate response for guest
    When I send a request to the Api
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "Missing API key"


  @authorization
  Scenario: Validate response for user
    Given I create a user
    And there is 1 chore type
    And the field "chore_type_id" with value "ct-a"
    And I use the user API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given there is 1 chore type
    And the field "chore_type_id" with value "ct-a"
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"


  Scenario: Get a chore type
    Given I create a user
    Given there is 1 chore type
    And the field "chore_type_id" with value "ct-a"
    And I use the user API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema
    And the Api response contains the expected data


  Scenario: Validate error response when getting a non existing chore type
    Given I create a user
    And the field "chore_type_id" with value "ct-a"
    And I use the user API key
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "ChoreType with id=ct-a does not exist"


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
