import pytest
from behave.model import Feature

from common.openapi import *
from constants import *
from metatests.core import *


def test_validate_xcorrelator_in_headers(feature: Feature):
    operation_id = get_operation_id_by_feature(feature)
    headers = get_request_headers(operation_id=operation_id)
    msg = f"[{operation_id}] X-Correlator header is mandatory"
    assert "X-Correlator" in headers, msg


def test_openapi_headers_title_cased(feature: Feature):
    operation_id = get_operation_id_by_feature(feature)
    headers = get_request_headers(operation_id=operation_id)
    for header in headers:
        expected = "-".join([x.title() for x in header.split("-")])
        msg = f"[{operation_id}] Header {header!r} should be {expected!r}"
        assert header == expected, msg


def test_get_operations_with_parameter_404(feature: Feature):
    operation_id = get_operation_id_by_feature(feature)
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


def test_post_operations_should_define_400_response(feature: Feature):
    operation_id = get_operation_id_by_feature(feature)
    method = get_method(operation_id)
    if method != "POST":
        return

    if get_request_body(operation_id=operation_id) is None:
        msg = f"[{operation_id}] 400 response is declared"
        assert 400 not in get_response_codes(operation_id=operation_id), msg
    else:
        msg = f"[{operation_id}] 400 response is not declared"
        assert 400 in get_response_codes(operation_id=operation_id), msg


def test_post_operations_should_define_422_response(feature: Feature):
    operation_id = get_operation_id_by_feature(feature)
    method = get_method(operation_id)
    if method != "POST":
        return

    if get_request_body(operation_id=operation_id) is None:
        msg = f"[{operation_id}] 422 response is declared"
        assert 422 not in get_response_codes(operation_id=operation_id), msg
    else:
        msg = f"[{operation_id}] 422 response is not declared"
        assert 422 in get_response_codes(operation_id=operation_id), msg


def test_204_delete_operations(feature: Feature):
    operation_id = get_operation_id_by_feature(feature)
    method = get_method(operation_id)
    if method != "DELETE":
        return

    response_codes = get_response_codes(operation_id=operation_id)
    assert 204 in response_codes
    assert 200 not in response_codes


@pytest.mark.responses
def test_all_status_codes_covered(feature: Feature):
    operation_id = get_operation_id_by_feature(feature)
    operation = get_operation(operation_id=operation_id)
    expected = list({int(x) for x in operation["responses"].keys()})
    expected.sort()

    actual_status_codes = get_reached_status_codes_by_operation_id(operation_id)
    msg = f"{operation_id}: Status codes should be the same as defined in the OpenAPI spec"
    assert actual_status_codes == expected, msg


@pytest.mark.responses
def test_responses_in_examples(feature: Feature):
    operation_id = get_operation_id_by_feature(feature)
    operation = get_operation(operation_id=operation_id)
    expected = list({int(x) for x in operation["responses"].keys()})
    expected.sort()

    error_messages = get_reached_error_messages_by_operation_id(operation_id)

    for status_code, messages in error_messages.items():
        if status_code in SPECIAL_STATUS_CODES:
            continue

        examples = get_examples(operation_id=operation_id, code=status_code)
        examples = [dumps(x) for x in examples]

        messages = list(messages)
        messages.sort()
        examples.sort()

        msg = f"{operation_id} - {status_code}: Error messages should be the same as defined in the OpenAPI spec"
        assert messages == examples, msg
