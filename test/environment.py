from collections import defaultdict
from json import dumps, loads
from pathlib import Path
from uuid import uuid4

import allure
import requests
from hamcrest import *
from toolium.behave.environment import after_all as tlm_after_all
from toolium.behave.environment import after_feature as tlm_after_feature
from toolium.behave.environment import after_scenario as tlm_after_scenario
from toolium.behave.environment import before_all as tlm_before_all
from toolium.behave.environment import before_feature as tlm_before_feature
from toolium.behave.environment import before_scenario as tlm_before_scenario
from toolium.utils import dataset

from common.constants import (
    COMMON_SCENARIOS,
    DEFINED_ERROR_STEP,
    DEFINED_OK_STATUS_CODE_STEP_PATTERN,
    SPECIAL_STATUS_CODES,
)
from common.db import reset_databases
from common.openapi import get_current_operation, get_examples


def before_all(context):
    tlm_before_all(context)
    context.admin_api_key = "bc6acdd7-9de0-495f-86ea-20beda48d626"


def before_feature(context, feature):
    tlm_before_feature(context, feature)
    context.api = Path(feature.filename).parent.name
    context.resource = Path(feature.filename).stem
    context.operation_id = context.resource
    context.storage = {}
    context.status_codes = set()
    context.error_messages = defaultdict(set)
    context.correlator = str(uuid4())

    validate_feature_tests(context, feature)


def get_dataset():
    return {}


def get_settings():
    settings = {}
    settings_path = Path(__file__).parent / "settings/settings.json"
    settings = loads(settings_path.read_text())
    settings.update(get_dataset())
    return settings


def before_scenario(context, scenario):
    tlm_before_scenario(context, scenario)
    check_naming(context, scenario)

    dataset.project_config = get_settings()
    context.session = requests.Session()

    reset_databases()
    context.res = None


def register_allure_stdout_stderr(context):
    stdout = None if not context.stdout_capture else context.stdout_capture.getvalue()
    stderr = None if not context.stderr_capture else context.stderr_capture.getvalue()
    logs = None if not context.log_capture else context.log_capture.getvalue()

    if stdout:
        allure.attach(
            stdout, name="stdout", attachment_type=allure.attachment_type.TEXT
        )
    if stderr:
        allure.attach(
            stderr, name="stderr", attachment_type=allure.attachment_type.TEXT
        )
    if logs:
        allure.attach(logs, name="logs", attachment_type=allure.attachment_type.TEXT)


def after_scenario(context, scenario):
    if scenario.status == "failed":
        text = f"X-CORRELATOR FOR DEBUGGING: {context.correlator}"
        allure.attach(
            text, name="x-correlator", attachment_type=allure.attachment_type.TEXT
        )
    register_allure_stdout_stderr(context)
    tlm_after_scenario(context, scenario)


def after_feature(context, feature):
    tlm_after_feature(context, feature)
    validate_feature_status_codes(context, feature)


def after_all(context):
    tlm_after_all(context)


def check_naming(context, scenario):
    scenario_name = scenario.name
    step_names = [step.name for step in scenario.steps]

    if not scenario_name[0].isupper():
        name = scenario_name[0].upper() + scenario_name[1:]
        msg = f"Scenario name should be titled ({name})"
        raise AssertionError(msg)
    if "validate error" in scenario_name.lower():
        assert "validate error response" in scenario_name.lower()
        check_stattus_code_is_registered(context, scenario)

    step_cheks = [DEFINED_OK_STATUS_CODE_STEP_PATTERN.search(x) for x in step_names]
    if any(step_cheks):
        match = next(x for x in step_cheks if x)
        if match.group(1)[0] != "2":
            check_stattus_code_is_registered(context, scenario)


def check_stattus_code_is_registered(context, scenario):
    step_names = [step.name for step in scenario.steps]
    info = f"{context.operation_id} - {scenario.name}"
    msg = f"[{info}] Must check error status code is registered"
    assert_that(DEFINED_ERROR_STEP, is_in(step_names), msg)


def validate_feature_tests(context, feature):
    resource_from_feature_name = feature.name.split(" - ")[-1]
    assert_that(
        resource_from_feature_name,
        equal_to(context.resource),
        "Feature name should be the same as the filename",
    )
    scenario_names = [scenario.name for scenario in feature.scenarios]
    for scenario_name in COMMON_SCENARIOS:
        assert_that(
            scenario_name,
            is_in(scenario_names),
            f"Feature {context.operation_id} should have the common scenario {scenario_name!r}",
        )


def validate_feature_status_codes(context, feature):
    operation = get_current_operation(context)
    expected = list({int(x) for x in operation["responses"].keys()})
    expected.sort()

    actual = list(context.status_codes)
    actual.sort()

    assert_that(
        actual,
        equal_to(expected),
        f"{context.operation_id}: Status codes should be the same as defined in the OpenAPI spec",
    )

    for status_code, messages in context.error_messages.items():
        if status_code in SPECIAL_STATUS_CODES:
            continue

        examples = get_examples(context, status_code)
        examples = [dumps(x) for x in examples]

        messages = list(messages)
        messages.sort()
        examples.sort()
        assert_that(
            messages,
            equal_to(examples),
            f"{context.operation_id} - {status_code}: Error messages should"
            " be the same as defined in the OpenAPI spec",
        )
