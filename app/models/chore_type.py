from pydantic import BaseModel, Field, validator


class ChoreType(BaseModel):
    id: str = Field(min_length=1, max_length=25, regex="^[a-z-]+$")
    name: str = Field(min_length=1, max_length=50)
    description: str = Field(min_length=1, max_length=255)

    @validator("name", "description", pre=True)
    def strip(cls, v):
        if isinstance(v, str):
            return v.strip()
        return v
