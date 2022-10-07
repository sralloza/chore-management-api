from json import loads
from pathlib import Path

import allure
import requests
from toolium.behave.environment import after_all as tlm_after_all
from toolium.behave.environment import after_feature as tlm_after_feature
from toolium.behave.environment import after_scenario as tlm_after_scenario
from toolium.behave.environment import before_all as tlm_before_all
from toolium.behave.environment import before_feature as tlm_before_feature
from toolium.behave.environment import before_scenario as tlm_before_scenario
from toolium.utils import dataset

from common.api import _send_request
from common.db import reset_databases


def before_all(context):
    tlm_before_all(context)
    context.admin_token = "bc6acdd7-9de0-495f-86ea-20beda48d626"


def before_feature(context, feature):
    tlm_before_feature(context, feature)
    context.api = Path(feature.filename).parent.name
    context.resource = feature.name.split(" - ")[-1]
    context.operation_id = context.resource
    context.storage = {}


def get_dataset():
    dataset = {}
    apis_path = Path(__file__).parent / "settings/endpoints.json"
    dataset["apis"] = loads(apis_path.read_text())

    return dataset


def get_settings():
    settings = {}
    settings_path = Path(__file__).parent / "settings/settings.json"
    settings = loads(settings_path.read_text())
    settings.update(get_dataset())
    return settings


def before_scenario(context, scenario):
    tlm_before_scenario(context, scenario)
    check_naming(scenario)

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
    register_allure_stdout_stderr(context)
    tlm_after_scenario(context, scenario)


def after_feature(context, feature):
    tlm_after_feature(context, feature)


def after_all(context):
    tlm_after_all(context)


def check_naming(scenario):
    scenario_name = scenario.name
    if not scenario_name[0].isupper():
        name = scenario_name[0].upper() + scenario_name[1:]
        msg = f"Scenario name should be titled ({name})"
        raise AssertionError(msg)
    if "validate error" in scenario_name.lower():
        assert "validate error response" in scenario_name.lower()
