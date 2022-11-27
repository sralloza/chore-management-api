from behave.model import Scenario

from constants import *
from metatests.core import *


def test_scenario_name_is_upper(scenario: Scenario):
    if not scenario.name[0].isupper():
        name = scenario.name[0].upper() + scenario.name[1:]
        msg = f"Scenario name should be titled ({name})"
        raise AssertionError(msg)
