from pydantic import BaseModel, Field

from .common import USER_ID_FIELD


class Rotation(BaseModel):
    week_id: str = USER_ID_FIELD
    rotation: int
    user_ids_hash: str = Field(min_length=64, max_length=64)
