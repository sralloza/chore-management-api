@api.system
@listDeactivatedWeeksSystem
Feature: System API - listDeactivatedWeeksSystem

  As an admin or a user
  I want to list the weeks that will have the weekly chores creation deactivated


  @authorization
  Scenario: Validate response for guest
    When I send a request to the Api
    Then the response status code is "401"
    And the response status code is defined
    And the error message is "Missing API key"


  @authorization
  Scenario: Validate response for user
    Given I create a user and I use the user API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  @authorization
  Scenario: Validate response for admin
    Given I deactivate the chore creation for the week 2022.01
    And I use the admin API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined


  Scenario: Get the list of deactivated weeks when there is none
    Given I create a user and I use the user API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the Api response contains the expected data
    """
    []
    """


  Scenario: Get the list of deactivated weeks when there are somw
    Given I deactivate the chore creation for the week "2022.01"
    And I deactivate the chore creation for the week "2022.02"
    And I deactivate the chore creation for the week "2022.03"
    And I create a user and I use the user API key
    When I send a request to the Api
    Then the response status code is "200"
    And the response status code is defined
    And the Api response contains the expected data
