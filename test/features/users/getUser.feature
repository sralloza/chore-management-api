@api.users
@getUser
Feature: Users API - getUser

  As an admin, flat admin or user
  I want to access a user's data or I want to access myself's data

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
    And the field "user_id" saved as "created_user_id"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for flat admin
    Given I create a flat with a user and I use the flat API key
    And the field "user_id" saved as "created_user_id"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given I create a flat with a user
    And the field "user_id" saved as "created_user_id"
    And the "[CONTEXT:created_flat_name]" as X-Flat header
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario Outline: Get tenant by id with the user API key
    Given I create a flat with a user and I use the user API key
    And the field "user_id" with value "<user_id>"
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the response body is validated against the json-schema
    And the Api response contains the expected data

    Examples: user_id = <user_id>
      | user_id                   |
      | [CONTEXT:created_user_id] |
      | me                        |


  Scenario: Validate error response when using keyword me with the admin API key
    Given I create a flat
    And I use the admin API key
    And the field "user_id" with value "me"
    And the "[CONTEXT:created_flat_name]" as X-Flat header
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Can't use the special keyword me with the admin API key"
    And the response error message is defined


  Scenario: Validate error response when using keyword me with the flat admin API key
    Given I create a flat and I use the flat API key
    And the field "user_id" with value "me"
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Can't use the special keyword me with a flat administration API key"
    And the response error message is defined


  Scenario: Validate error response when requesting other user's data
    Given I create a flat with a user
    And there is 1 user
    And the field "user_id" with value "user-1"
    And I use the user API key
    When I send a request to the Api
    Then the response status code is "403"
    And the response status code is defined
    And the error message is "You don't have permission to access this user's data"
    And the response error message is defined


  Scenario: Validate error response when requesting a non existing user with the admin API key
    Given I create a flat
    And I use the admin API key
    And the "[CONTEXT:created_flat_name]" as X-Flat header
    And the field "user_id" with value "xxx"
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "User not found: xxx"
    And the response error message is defined


  Scenario: Validate error response when requesting a non existing user with the flat administration API key
    Given I create a flat and I use the flat API key
    And the field "user_id" with value "xxx"
    When I send a request to the Api
    Then the response status code is "404"
    And the response status code is defined
    And the error message is "User not found: xxx"
    And the response error message is defined

  Scenario: Validate error response when using the X-Flat header without the admin API key
    Given I create a flat and I use the flat API key
    And the field "user_id" with value "xxx"
    And the "xxx" as X-Flat header
    When I send a request to the Api
    Then the response status code is "400"
    And the response status code is defined
    And the error message is "Can't use the X-Flat header without the admin API key"
    And the response error message is defined


  Scenario: Validate error response when using the admin API key without the X-Flat header
    Given I use the admin API key
    And the field "user_id" with value "xxx"
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
