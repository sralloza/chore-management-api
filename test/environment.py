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

from common.api_v2 import _send_request
from common.db import reset_databases


def before_all(context):
    tlm_before_all(context)


def before_feature(context, feature):
    tlm_before_feature(context, feature)
    context.api = Path(feature.filename).parent.name
    context.resource = feature.name.split(" - ")[-1]


def get_dataset():
    dataset = {}
    apis_path = Path(__file__).parent / "settings/apis.json"
    dataset["apis"] = loads(apis_path.read_text())

    return dataset


def before_scenario(context, scenario):
    tlm_before_scenario(context, scenario)
    dataset.project_config = get_dataset()
    context.session = requests.Session()

    context.get = lambda path, **kwargs: _send_request(context, "GET", path, **kwargs)
    context.post = lambda path, **kwargs: _send_request(context, "POST", path, **kwargs)

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
