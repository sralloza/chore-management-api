@api.flats
@createFlat
Feature: Flats API - createFlat

    As a user
    After the admin sends me the create code
    I want to create a flat


    @authorization
    Scenario: Validate response for guest
        Given I request a flat create code
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "200"
        And the response status code is defined


    @authorization
    Scenario: Validate response for user
        Given I create a flat with a user
        And I request a flat create code
        And I use the user API key
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "200"
        And the response status code is defined


    @authorization
    Scenario: Validate response for flat owner
        Given I create a flat
        And I request a flat create code
        And I use the flat API key
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "200"
        And the response status code is defined


    @authorization
    Scenario: Validate response for admin
        Given I create a flat
        And I request a flat create code
        And I use the admin API key
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "200"
        And the response status code is defined


    Scenario: Create flat
        Given I request a flat create code
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "200"
        And the response body is validated against the json-schema
        And the Api response contains the expected data
            | skip_param |
            | name       |
            | api_key    |


    Scenario: Validate error response when using an invalid create code
        When I send a request to the Api with body params
            | param_name  | param_value         |
            | create_code | invalid_create_code |
            | name        | test-flat           |
        Then the response status code is "422"
        And the response status code is defined
        And the response contains the following validation errors
            | value               | msg                                 | param         | location |
            | invalid_create_code | body.create_code is not a valid JWT | "create_code" | "body"   |



    Scenario: Validate error response when using the same create code twice
        Given I request a flat create code
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "200"
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "403"
        And the response status code is defined
        And the error message is "Invalid create code"


    Scenario: Validate error response when using an expired token
        When I send a request to the Api with body params
            | param_name  | param_value                              |
            | create_code | [CONF:examples.expired_flat_create_code] |
            | name        | test-flat                                |
        Then the response status code is "403"
        And the response status code is defined
        And the error message is "Invalid create code"


    Scenario: Validate error response when the flat name is already taken
        Given I request a flat create code
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "200"
        Given I request a flat create code
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "409"
        And the response status code is defined
        And the error message is "Flat already exists"



    Scenario: Validate that the token only expires if a flat is created
        Given I request a flat create code
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "200"
        Given I request a flat create code
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat             |
        Then the response status code is "409"
        And the response status code is defined
        When I send a request to the Api with body params
            | param_name  | param_value           |
            | create_code | [CONTEXT:create_code] |
            | name        | test-flat-secondary   |
        Then the response status code is "200"
        And the response body is validated against the json-schema


    Scenario: Validate error response when the body is not a valid json
        Given I request a flat create code
        When I send a request to the Api with body
            """
            invalid json
            """
        Then the response status code is "400"
        And the response status code is defined
        And the error message is "Request body is not a valid JSON"


    @run
    Scenario Outline: Validate error response when params are not valid
        Given I request a flat create code
        When I send a request to the Api with body params
            | param_name  | param_value   |
            | create_code | <create_code> |
            | name        | <name>        |
        Then the response status code is "422"
        And the response status code is defined
        And the response body is a valid json
        And the response contains the following validation errors
            | value   | msg   | param   | location   |
            | <value> | <msg> | <param> | <location> |

        Examples: create_code=<create_code>, name=<name>, location=<location>, param=<param>, msg=<msg>, value=<value>
            | create_code           | name      | location | param       | msg                                                             | value   |
            | [NONE]                | flat-test | body     | create_code | body.create_code is required                                    | [NONE]  |
            | [NULL]                | flat-test | body     | create_code | body.create_code is required                                    | [NULL]  |
            | [EMPTY]               | flat-test | body     | create_code | body.create_code is not a valid JWT                             | [EMPTY] |
            | XXXXXXX               | flat-test | body     | create_code | body.create_code is not a valid JWT                             | XXXXXXX |
            | [CONTEXT:create_code] | [NONE]    | body     | name        | body.name is required                                           | [NONE]  |
            | [CONTEXT:create_code] | [NULL]    | body     | name        | body.name is required                                           | [NULL]  |
            | [CONTEXT:create_code] | Invalid   | body     | name        | body.name does not match the pattern '[CONF:pattern.flat_name]' | Invalid |
