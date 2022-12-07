from fastapi import Path

WEEK_ID_REGEX = r"^\d{4}\.(0[1-9]|[1-4][0-9]|5[0-4])$"
WEEK_ID_EXPANDED_REGEX = r"(\d{4}\.(0[1-9]|[1-4][0-9]|5[0-4])|next|current|last)$"

WEEK_ID_PATH = Path(
    ...,
    regex=WEEK_ID_EXPANDED_REGEX,
    description="""Week identifier. Special keywords `next`,
    `current` and `last` are also allowed.""",
)

USER_ID_PATH = Path(
    ..., description="User identifier. Special keyword `me` is also allowed."
)
