from sqlmodel import Field, SQLModel


class Chore(SQLModel, table=True):
    id: int = Field(primary_key=True)
    chore_type: str = Field(max_length=25)
    done: bool = Field(default=False)
    user_id: str = Field(max_length=40)
    week_id: str = Field(max_length=7)
