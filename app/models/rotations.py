from pydantic import BaseModel, Field


class Rotation(BaseModel):
    week_id: str = Field(regex=r"^\d{4}\.\d{2}$")
    rotation: int
    user_ids_hash: str = Field(min_length=64, max_length=64)
