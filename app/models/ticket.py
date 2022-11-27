from sqlmodel import Field, SQLModel


class Ticket(SQLModel, table=True):
    id: int = Field(primary_key=True)
    chore_type_id: str = Field(max_length=25)
    user_id: str = Field(max_length=40)
    tickets: int
