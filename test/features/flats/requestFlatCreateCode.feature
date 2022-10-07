@api.flats
@requestFlatCreateCode
@sanity
Feature: Flats API - requestFlatCreateCode

    As an admin
    I want to get a code for creating a flat


    @authorization
    Scenario: Validate response for guest
        When I send a request to the Api
        Then the response status code is "401"
        And the response status code is defined
        And the error message is "Missing API key"


    # IMPEDDED: need to implement getFlat operation
    # @authorization
    # Scenario: Validate response for flat admin
    #     Given I create a flat
    #     And I use a flat token
    #     When I send a request to the Api
    #     Then the response status code is "403"
    #     And the error message is "Admin access required"


    # IMPEDDED: need to implement getFlat operation
    # @authorization
    # Scenario: Validate response for tenant
    #     Given there is 1 flat
    #     Given there is 1 tenant
    #     And I use a tenant's token
    #     When I send a request to the Api
    #     Then the response status code is "200"

    # Scenario: Validate response for flat admin


    # IMPEDDED: need to implement getFlat operation
    # @authorization
    # Scenario: Validate response for admin
    #     Given there is 1 tenant
    #     And I use the admin token
    #     When I send a request to the Api
    #     Then the response status code is "200"


    Scenario: Request flat create code
        Given I use the admin token
        When I send a request to the Api
        Then the response status code is "200"
        And the response body is validated against the json-schema
