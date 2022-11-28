from pydantic import BaseModel, Field


class ChoreType(BaseModel):
    id: str = Field(max_length=25)
    name: str = Field(max_length=50)
    description: str = Field(max_length=255)
