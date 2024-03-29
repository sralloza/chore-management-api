import re

import pytest
from behave.model import Feature

from common.openapi import (
    get_examples,
    get_method,
    get_operation,
    get_operation_path,
    get_parameters,
    get_request_body,
    get_request_headers,
    get_request_path_parameters,
    get_response_codes,
    get_responses,
    get_security_schemas,
)
from metatests.core import (
    get_operation_id_by_feature,
    get_reached_status_codes_by_operation_id,
)

PATH_PARAM_REGEX = re.compile(r"\{([\w]+)\}")
SECURITY_SCHEMAS = ["AdminApiKey", "FlatAdminApiKey", "UserApiKey"]
SECURITY_EXAMPLES = {
    "AdminApiKey": "Admin access required",
    "FlatAdminApiKey": "Flat administration access required",
    "UserApiKey": "User access required",
}
XCORRELATOR_HEADER_RESPONSE = {
    "description": "Correlation id for the different services",
    "schema": {"type": "string"},
}


def test_validate_xcorrelator_in_headers(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    headers = get_request_headers(operation_id=operation_id)
    msg = f"[{operation_id}] X-Correlator header is mandatory"
    assert "X-Correlator" in headers, msg


def test_openapi_headers_title_cased(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    headers = get_request_headers(operation_id=operation_id)
    for header in headers:
        expected = "-".join([x.title() for x in header.split("-")])
        msg = f"[{operation_id}] Header {header!r} should be {expected!r}"
        assert header == expected, msg


def test_path_params_camel_cased(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    params = get_request_path_parameters(operation_id=operation_id)
    for param in params:
        assert "-" not in param
        expected = "_".join([x.lower() for x in param.split("_")])
        assert param == expected


def test_defined_path_params(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    defined_path_params = get_request_path_parameters(operation_id=operation_id)
    path = get_operation_path(operation_id)
    real_path_params = [x.group(1) for x in PATH_PARAM_REGEX.finditer(path)]
    for param in real_path_params:
        assert param in defined_path_params, "Path parameter is not defined"

    for param in defined_path_params:
        assert param in real_path_params, "Path parameter is not used"


def test_get_operations_with_parameter_404(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    method = get_method(operation_id)
    if method != "GET":
        return
    parameters = get_parameters(operation_id=operation_id)
    path_parameters = [x["name"] for x in parameters if x["in"] == "path"]
    if path_parameters:
        msg = f"[{operation_id}] 404 response is not declared ({path_parameters})"
        assert 404 in get_response_codes(operation_id=operation_id), msg
    else:
        msg = f"[{operation_id}] 404 response is declared, but has no path parameters"
        assert 404 not in get_response_codes(operation_id=operation_id), msg


def test_post_operations_should_define_400_response(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    method = get_method(operation_id)
    if method != "POST":
        return

    if get_request_body(operation_id=operation_id) is None:
        msg = f"[{operation_id}] 400 response is declared"
        assert 400 not in get_response_codes(operation_id=operation_id), msg
    else:
        msg = f"[{operation_id}] 400 response is not declared"
        assert 400 in get_response_codes(operation_id=operation_id), msg


def test_post_operations_should_define_422_response(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    method = get_method(operation_id)
    if method != "POST":
        return

    if get_request_body(operation_id=operation_id) is None:
        msg = f"[{operation_id}] 422 response is declared"
        assert 422 not in get_response_codes(operation_id=operation_id), msg
    else:
        msg = f"[{operation_id}] 422 response is not declared"
        assert 422 in get_response_codes(operation_id=operation_id), msg


def test_flat_name_path_and_x_flat_header(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    headers = get_request_headers(operation_id=operation_id)
    path_params = get_request_path_parameters(operation_id=operation_id)
    if "flat_name" in path_params:
        assert "X-Flat" not in headers


def test_validate_security_schema(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    security_schemas = get_security_schemas(operation_id)
    defined_status_codes = get_response_codes(operation_id)
    if len(security_schemas) == 0:
        assert 401 not in defined_status_codes
        return

    assert 401 in defined_status_codes
    assert len(security_schemas) == 1, "Only one security schema is allowed"
    schema = security_schemas[0]

    assert schema in SECURITY_SCHEMAS, f"Unknown security schema {schema!r}"

    examples = get_examples(operation_id=operation_id, code=403)
    expected = {"message": SECURITY_EXAMPLES[schema]}
    msg = (
        f"Example {expected!r} is not defined for 403 "
        f"response and {schema!r} security schema"
    )
    assert expected in examples, msg


def test_204_delete_operations(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    method = get_method(operation_id)
    if method != "DELETE":
        return

    response_codes = get_response_codes(operation_id=operation_id)
    assert 204 in response_codes
    assert 200 not in response_codes


@pytest.mark.responses
def test_all_status_codes_covered(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    operation = get_operation(operation_id=operation_id)
    expected = list({int(x) for x in operation["responses"].keys()})
    expected.sort()

    actual_status_codes = get_reached_status_codes_by_operation_id(operation_id)
    msg = (
        f"{operation_id}: Status codes should be the same "
        "as defined in the OpenAPI spec"
    )
    assert actual_status_codes == expected, msg


def test_xcorrelator_in_responses(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    responses = get_responses(operation_id=operation_id)
    for response in responses:
        assert "headers" in response
        assert "X-Correlator" in response["headers"]
        correlator_header = response["headers"]["X-Correlator"]
        assert correlator_header == XCORRELATOR_HEADER_RESPONSE
