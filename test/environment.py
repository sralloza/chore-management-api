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

from common.db import reset_databases
from common.openapi import *
from metatests.constants import *


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
    validate_feature_status_codes(context)


def after_all(context):
    tlm_after_all(context)


# TODO: Move this test from behave to pytest
# It should be run after the behave tests
def validate_feature_status_codes(context):
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
