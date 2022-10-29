@api.flats
@editFlatSettings
Feature: Flats API - editFlatSettings

    As a flat admin
    I want to edit the flat's settings


    @authorization
    Scenario: Validate response for guest
        Given the field "flat_name" with value "test-flat"
        When I send a request to the Api
        Then the response status code is "401"
        And the response status code is defined
        And the error message is "Missing API key"


    @authorization
    Scenario: Validate response for user
        Given the field "flat_name" with value "test-flat"
        And I create a flat with a user and I use the user API key
        When I send a request to the Api
        Then the response status code is "403"
        And the response status code is defined
        And the error message is "Flat administration access required"


    @authorization
    Scenario: Validate response for flat owner
        Given the field "flat_name" with value "test-flat"
        And I create a flat and I use the flat API key
        When I send a request to the Api
        Then the response status code is "200"
        And the response status code is defined


    @authorization
    Scenario: Validate response for admin
        Given the field "flat_name" with value "test-flat"
        And I create a flat
        And the request headers
            | header | value     |
            | x-flat | test-flat |
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "200"
        And the response status code is defined


    Scenario Outline: Edit flat settings when it exists
        Given the field "flat_name" with value "<real_flat_name>"
        And I create a flat with a user and I use the flat API key
        # After user is created we must replace the flat_name with real sent value in URL
        Given the field "flat_name" with value "<flat_name_param>"
        When I send a request to the Api with body params
            | param_name         | param_value     |
            | assignment_order.0 | <user_id>       |
            | rotation_sign      | <rotation_sign> |
        Then the response status code is "200"
        And the response body is validated against the json-schema
        And the Api response contains the expected data
            """
            {
                "assignment_order": [
                    <user_id>
                ],
                "rotation_sign": "<rotation_sign>"
            }
            """

        Examples: flat_name = <flat_name_param>, user_id = <user_id>, rotation_sign = <rotation_sign>
            | flat_name_param | real_flat_name | user_id                   | rotation_sign |
            | test-flat       | test-flat      | [CONTEXT:user_id_created] | positive      |
            | test-flat       | test-flat      | [CONTEXT:user_id_created] | negative      |
            | me              | test-flat      | [CONTEXT:user_id_created] | positive      |
            | me              | test-flat      | [CONTEXT:user_id_created] | negative      |


    Scenario: Validate error response when using the me keyword with the admin API key
        Given the field "flat_name" with value "me"
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "400"
        And the response status code is defined
        And the error message is "Can't use the me keyword with the admin API key"


    Scenario: Validate error response when the flat doesn't exist
        Given the field "flat_name" with value "invalid_flat"
        And I use the admin API key
        When I send a request to the Api
        Then the response status code is "404"
        And the response status code is defined
        And the error message is "Flat not found: invalid_flat"


    Scenario Outline: Validate error response when sending invalid data
        Given the field "flat_name" with value "test-flat"
        And I create a flat with a user and I use the flat API key
        When I send a request to the Api with body params
            | param_name         | param_value     |
            | assignment_order   | [LIST:[]]       |
            | assignment_order.0 | <user_id>       |
            | rotation_sign      | <rotation_sign> |
        Then the response status code is "422"
        And the response status code is defined
        And the response contains the following validation errors
            | location | param   | msg   | value   |
            | body     | <param> | <msg> | <value> |


        Examples: user_id = <user_id>, rotation_sign = <rotation_sign>, param = <param>, msg = <msg>, value = <value>
            | user_id   | rotation_sign | param            | value         | msg                                                                |
            | [NONE]    | whatever      | rotation_sign    | whatever      | body.rotation_sign must be either 'positive' or 'negative'         |
            | [INT:123] | [NONE]        | assignment_order | [LIST:[123]]  | body.assignment_order contains invalid user ids or is missing some |
            | [NONE]    | [NONE]        | assignment_order | [LIST:[]]     | body.assignment_order contains invalid user ids or is missing some |
            | xxxx      | [NONE]        | assignment_order | [LIST:['xxxx']] | body.assignment_order contains invalid user ids or is missing some |
