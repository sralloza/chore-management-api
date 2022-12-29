from fastapi import Header, Path

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

LANG_HEADER = Header("en", alias="Accept-Language", description="Language code")
