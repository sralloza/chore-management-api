from pathlib import Path

import pytest
from behave.parser import parse_feature

from metatests.core import get_operation_id_by_scenario as gop_id


def get_features():
    features = []
    for feature_file in Path(__file__).parent.joinpath("features").glob("**/*.feature"):
        features.append(parse_feature(feature_file.read_text(), "en", feature_file))
    return features


FEATURES = [x for x in get_features() if "old" not in x.tags]
SCENARIOS = [x for feature in FEATURES for x in feature.scenarios]


@pytest.fixture(params=FEATURES, ids=[f.name for f in FEATURES])
def feature(request):
    return request.param


@pytest.fixture(params=SCENARIOS, ids=[f"{gop_id(f)} - {f.name}" for f in SCENARIOS])
def scenario(request):
    return request.param
