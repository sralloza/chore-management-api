from functools import lru_cache
from pathlib import Path

from behave.model import Feature, Scenario

from metatests.constants import DEFINED_ERROR_STEP


def get_operation_id_by_feature(feature: Feature):
    return get_operation_id_by_filename(feature.location.filename)


def get_operation_id_by_scenario(scenario: Scenario):
    return get_operation_id_by_filename(scenario.location.filename)


@lru_cache()
def get_operation_id_by_filename(filename: str):
    return Path(filename).stem


def check_status_code_is_registered(scenario: Scenario):
    operation_id = get_operation_id_by_scenario(scenario)
    step_names = [step.name for step in scenario.steps]
    info = f"{operation_id} - {scenario.name}"
    msg = f"[{info}] Must check error status code is registered"
    assert DEFINED_ERROR_STEP in step_names, msg
