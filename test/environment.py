from json import loads
from pathlib import Path
from shutil import rmtree
from uuid import uuid4

import allure
import requests
from toolium.behave.environment import after_all as tlm_after_all
from toolium.behave.environment import after_feature as tlm_after_feature
from toolium.behave.environment import after_scenario as tlm_after_scenario
from toolium.behave.environment import before_all as tlm_before_all
from toolium.behave.environment import before_feature as tlm_before_feature
from toolium.behave.environment import before_scenario as tlm_before_scenario
from toolium.utils import dataset

from common.db import reset_databases
from common.openapi import *

RESPONSES_FOLDER = Path(__file__).parent / "output" / "responses"


def before_all(context):
    tlm_before_all(context)
    context.admin_api_key = "bc6acdd7-9de0-495f-86ea-20beda48d626"
    responses_folder = RESPONSES_FOLDER
    if responses_folder.exists():
        rmtree(responses_folder)


def before_feature(context, feature):
    tlm_before_feature(context, feature)
    context.api = Path(feature.filename).parent.name
    context.operation_id = Path(feature.filename).stem
    context.storage = {}
    dataset.project_config = get_settings()

    responses_folder = RESPONSES_FOLDER / context.operation_id
    if responses_folder.exists():
        rmtree(responses_folder)


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

    context.session = requests.Session()
    context.correlator = str(uuid4())

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
        allure.attach(
            {"correlator": context.correlator},
            name="x-correlator",
            attachment_type=allure.attachment_type.JSON,
        )
        response_file = RESPONSES_FOLDER / f"{context.correlator}.json"
        if response_file.exists():
            response_file.unlink()

    register_allure_stdout_stderr(context)
    tlm_after_scenario(context, scenario)


def after_feature(context, feature):
    tlm_after_feature(context, feature)


def after_all(context):
    tlm_after_all(context)
