from pydantic import BaseModel, Field

from ..core.constants import WEEK_ID_REGEX


class Rotation(BaseModel):
    week_id: str = Field(regex=WEEK_ID_REGEX)
    rotation: int
    user_ids_hash: str = Field(min_length=64, max_length=64)
