from pydantic import BaseModel, validator

from .common import (
    CHORE_TYPE_DESCRIPTION_FIELD,
    CHORE_TYPE_ID_FIELD,
    CHORE_TYPE_NAME_FIELD,
)


class ChoreType(BaseModel):
    id: str = CHORE_TYPE_ID_FIELD
    name: str = CHORE_TYPE_NAME_FIELD
    description: str = CHORE_TYPE_DESCRIPTION_FIELD

    @validator("name", "description", pre=True)
    def strip(cls, v):
        if isinstance(v, str):
            return v.strip()
        return v
