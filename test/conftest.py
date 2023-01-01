from pathlib import Path

import pytest
from behave.parser import parse_feature
from metatests.core import get_operation_id_by_scenario as gop_id


def get_features(all_features=True):
    features = []
    for feature_file in Path(__file__).parent.joinpath("features").glob("**/*.feature"):
        if not all_features and "misc" in feature_file.parts:
            continue
        features.append(parse_feature(feature_file.read_text(), "en", feature_file))
    return features


# API features
API_FEATURES = [x for x in get_features(all_features=False) if "old" not in x.tags]
API_SCENARIOS = [x for feature in API_FEATURES for x in feature.scenarios]

# All features (including misc)
FEATURES = [x for x in get_features(all_features=True) if "old" not in x.tags]
SCENARIOS = [x for feature in FEATURES for x in feature.scenarios]


@pytest.fixture(params=API_FEATURES, ids=[f.name for f in API_FEATURES])
def api_feature(request):
    return request.param


@pytest.fixture(
    params=API_SCENARIOS, ids=[f"{gop_id(f)} - {f.name}" for f in API_SCENARIOS]
)
def api_scenario(request):
    return request.param


@pytest.fixture(params=FEATURES, ids=[f.name for f in FEATURES])
def feature(request):
    return request.param


@pytest.fixture(params=SCENARIOS, ids=[f"{gop_id(f)} - {f.name}" for f in SCENARIOS])
def scenario(request):
    return request.param
