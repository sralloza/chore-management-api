from fastapi import Path

from ..core.patterns import WEEK_ID_EXPANDED_REGEX

USER_ID_PATH = Path(
    ..., description="User identifier. Special keyword `me` is also allowed."
)
WEEK_ID_PATH = Path(
    ...,
    regex=WEEK_ID_EXPANDED_REGEX,
    description="""Week identifier. Special keywords `next`,
    `current` and `last` are also allowed.""",
)
