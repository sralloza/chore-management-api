@api.flats
@createFlat
@sanity
Feature: Flats API - createFlat

    As an admin
    I want to create a flat


    Scenario: Request flat create code
        Given I use the admin token
        When I send a request to the Api resource "requestFlatCreateCode"
        Then the response status code is "200"
        And I save the "code" attribute of the response as "create_code"
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "200"
        And the response body is validated against the json-schema


    Scenario: Validate error response when using an invalid create code
        When I send a request to the Api with body params
            | param_name  | param_value         |
            | create_code | invalid_create_code |
            | name        | test-flat           |
        Then the response status code is "422"
        And the response status code is defined
        And the error message is "Invalid create code"


    Scenario: Validate error response when using the same create code twice
        Given I use the admin token
        When I send a request to the Api resource "requestFlatCreateCode"
        Then the response status code is "200"
        And I save the "code" attribute of the response as "create_code"
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "200"
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "422"
        And the response status code is defined
        And the error message is "Invalid create code"


    Scenario: Validate error response when using an expired token
        When I send a request to the Api with body params
            | param_name  | param_value                              |
            | create_code | [CONF:examples.expired_flat_create_code] |
            | name        | test-flat                                |
        Then the response status code is "422"
        And the response status code is defined
        And the error message is "Invalid create code"


    Scenario: Validate error response when the flat name is already taken
        Given I use the admin token
        When I send a request to the Api resource "requestFlatCreateCode"
        Then the response status code is "200"
        And I save the "code" attribute of the response as "create_code"
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "200"
        Given I use the admin token
        When I send a request to the Api resource "requestFlatCreateCode"
        Then the response status code is "200"
        And I save the "code" attribute of the response as "create_code"
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "409"
        And the response status code is defined
        And the error message is "Flat already exists"
