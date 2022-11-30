from pathlib import Path

from behave.model import Feature

from common.openapi import get_request_headers
from constants import *
from metatests.core import *


def test_validate_feature_name(api_feature: Feature):
    resource = Path(api_feature.filename).stem
    resource_from_feature_name = api_feature.name.split(" - ")[-1]
    assert resource_from_feature_name == resource


def test_validate_common_scenarios(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    scenario_names = [scenario.name for scenario in api_feature.scenarios]
    msg = f"Feature: {operation_id} should have the common scenario "
    for scenario_name in COMMON_SCENARIOS:
        assert scenario_name in scenario_names, msg + repr(scenario_name)


def test_validate_xflat_header_scenarios(api_feature: Feature):
    operation_id = get_operation_id_by_feature(api_feature)
    scenario_names = [scenario.name for scenario in api_feature.scenarios]
    headers = get_request_headers(operation_id=operation_id)
    if "X-Flat" in headers:
        for scenario in X_FLAT_HEADER_SCENARIOS:
            msg = f"Feature: {operation_id} should have the flat scenario {scenario!r}"
            assert scenario in scenario_names, msg


def test_scenarios_should_leave_two_break_lines(feature: Feature):
    # The only cases where two break lines are accepted are:
    # Feature: description and examples
    pattern = re.compile(r".\n\n( +\w+)", re.MULTILINE)
    text = Path(feature.filename).read_text()
    for match in pattern.finditer(text):
        match_text = match.group(1)
        assert match_text.endswith("Examples") or match_text.endswith("As"), match

    # Each scenario must have two empty lines before it
    three_line_breaks = len(re.findall(r"\n\n\n", text))
    assert three_line_breaks == len(feature.scenarios)


def test_2_spaces_instead_of_4(feature: Feature):
    file = feature.location.filename
    file_content = Path(file).read_text()
    assert "    Scenario" not in file_content
    assert "  Scenario" in file_content
