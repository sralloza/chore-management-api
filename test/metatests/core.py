from collections import defaultdict
from functools import lru_cache
from json import dumps, loads
from pathlib import Path

from behave.model import Feature, Scenario

from constants import DEFINED_ERROR_STEP


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


def get_reached_status_codes_by_operation_id(operation_id: str):
    folder = Path(__file__).parent.parent / f"output/responses/{operation_id}"
    status_codes = set()
    for file in folder.glob("*.json"):
        status_codes.add(loads(file.read_text())["res"]["status_code"])
    status_codes = list(status_codes)
    status_codes.sort()
    return status_codes


def get_reached_error_messages_by_operation_id(operation_id: str):
    folder = Path(__file__).parent.parent / f"output/responses/{operation_id}"
    messages = defaultdict(set)
    for file in folder.glob("*.json"):
        res = loads(file.read_text())
        status_code = res["res"]["status_code"]
        if res["res"]["is_error"]:
            messages[status_code].add(dumps(res["res"]["body"]))
    return messages
