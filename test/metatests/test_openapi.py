from behave.model import Feature

from common.openapi import get_request_headers
from metatests.constants import *
from metatests.core import *


def test_validate_xcorrelator_in_headers(feature: Feature):
    operation_id = get_operation_id_by_scenario(feature)
    headers = get_request_headers(operation_id=operation_id)
    msg = f"[{operation_id}] X-Correlator header is mandatory"
    assert "X-Correlator" in headers, msg


def test_openapi_headers_title_cased(feature: Feature):
    operation_id = get_operation_id_by_scenario(feature)
    headers = get_request_headers(operation_id=operation_id)
    for header in headers:
        expected = "-".join([x.title() for x in header.split("-")])
        msg = f"[{operation_id}] Header {header!r} should be {expected!r}"
        assert header == expected, msg
