from behave.model import Scenario

from constants import *
from metatests.core import *


def test_scenario_name_is_upper(scenario: Scenario):
    breakpoint()
    if not scenario.name[0].isupper():
        name = scenario.name[0].upper() + scenario.name[1:]
        msg = f"Scenario name should be titled ({name})"
        raise AssertionError(msg)


def test_validate_error_response_scenario_names(scenario: Scenario):
    operation_id = get_operation_id_by_scenario(scenario)
    step_names = [step.name for step in scenario.steps]

    if "validate error" in scenario.name.lower():
        assert "validate error response" in scenario.name.lower()
        check_status_code_is_registered(scenario)

        info = f"{operation_id} - {scenario.name}"
        msg = f"[{info}] Must check error status code is registered"
        assert DEFINED_ERROR_STEP in step_names, msg


def test_always_check_status_code(scenario: Scenario):
    step_names = [step.name for step in scenario.steps]
    step_cheks = [DEFINED_OK_STATUS_CODE_STEP_PATTERN.search(x) for x in step_names]
    if any(step_cheks):
        match = next(x for x in step_cheks if x)
        if match.group(1)[0] != "2":
            check_status_code_is_registered(scenario)
