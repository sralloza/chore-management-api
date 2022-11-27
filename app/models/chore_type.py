from sqlmodel import Field, SQLModel


class ChoreType(SQLModel, table=True):
    id: str = Field(primary_key=True, max_length=25)
    name: str = Field(max_length=50)
    description: str = Field(max_length=255)
