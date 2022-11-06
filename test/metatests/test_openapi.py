from behave.model import Feature

from common.openapi import *
from metatests.constants import *
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
