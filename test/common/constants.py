import re

COMMON_SCENARIOS = (
    "Validate X-Correlator injection",
    "Validate X-Powered-By disabled",
    "Validate response for unauthorized user",
    "Validate response for guest",
    "Validate response for user",
    "Validate response for flat admin",
    "Validate response for admin",
)
DEFINED_ERROR_STEP = "the response error message is defined"
SPECIAL_STATUS_CODES = (404, 409, 422)
DEFINED_OK_STATUS_CODE_STEP_PATTERN = re.compile(r'the response status code is "(\d+)"')
