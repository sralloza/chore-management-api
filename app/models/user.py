from pydantic import validator
from sqlmodel import Field, SQLModel


class UserCreate(SQLModel):
    username: str = Field(min_length=2, max_length=25)
    id: str = Field(primary_key=True, min_length=4, max_length=40)

    @validator("id", pre=True)
    def check_blacklist(cls, v):
        if isinstance(v, str) and v.lower() == "me":
            raise ValueError("Forbidden user ID: me")
        return v


class User(UserCreate, table=True):
    api_key: str = Field(max_length=36, unique=True)
