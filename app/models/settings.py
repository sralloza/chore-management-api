from sqlmodel import Field, SQLModel


class Settings(SQLModel, table=True):
    # TODO: settings should have only one item
    primary_key: str = Field(primary_key=True, max_length=36)
    assignment_order: str = Field(max_length=2048)
    rotation_sign: str = Field(max_length=15)
