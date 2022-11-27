from pydantic import validator
from sqlalchemy import BigInteger
from sqlmodel import Field, SQLModel,Column
import time


class UserCreate(SQLModel):
    username: str = Field(min_length=2, max_length=25)
    id: str = Field(primary_key=True, min_length=4, max_length=40)

    @validator("id", pre=True)
    def check_blacklist(cls, v):
        if isinstance(v, str) and v.lower() == "me":
            raise ValueError("Forbidden user ID: me")
        return v


class UserSimple(UserCreate):
    pass


class User(UserCreate, table=True):
    api_key: str = Field(max_length=36, unique=True)
    created_at: int = Field(default_factory=lambda: time.time() * 10**6, sa_column=Column(BigInteger()))


class UserOutput(UserCreate):
    api_key: str
