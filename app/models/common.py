from pydantic import Field

from ..core.patterns import CHORE_TYPE_ID_REGEX, WEEK_ID_EXPANDED_REGEX, WEEK_ID_REGEX

CHORE_TYPE_ID_FIELD = Field(
    min_length=1,
    max_length=25,
    regex=CHORE_TYPE_ID_REGEX,
    description="Chore type identifier",
    example="clean-dishes",
)
CHORE_TYPE_NAME_FIELD = Field(
    min_length=1, max_length=50, description="Chore type name", example="Clean dishes"
)
CHORE_TYPE_DESCRIPTION_FIELD = Field(
    min_length=1,
    max_length=255,
    description="Chore type description",
    example="Clean dishes in the kitchen",
)

USER_ID_FIELD = Field(
    primary_key=True,
    min_length=4,
    max_length=40,
    description="User identifier",
    example="user1234",
)
USER_USERNAME_FIELD = Field(min_length=2, max_length=25)


WEEK_ID_FIELD = Field(
    regex=WEEK_ID_REGEX, description="Week identifier", example="2022.01"
)
WEEK_ID_EXTENDED_FIELD = Field(
    regex=WEEK_ID_EXPANDED_REGEX, description="Week identifier", example="2022.01"
)
