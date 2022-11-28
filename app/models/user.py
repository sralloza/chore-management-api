import time
from uuid import uuid4

from pydantic import BaseModel, Field, validator


class UserCreate(BaseModel):
    username: str = Field(min_length=2, max_length=25)
    id: str = Field(primary_key=True, min_length=4, max_length=40)

    @validator("id", pre=True)
    def check_blacklist(cls, v):
        if isinstance(v, str) and v.lower() == "me":
            raise ValueError("Forbidden user ID: me")
        return v


class UserSimple(UserCreate):
    pass


class UserCreateInner(UserCreate):
    api_key: str = Field(max_length=36, default_factory=lambda: str(uuid4()))
    created_at: int = Field(default_factory=lambda: int(time.time() * 10**6))


class User(UserCreate):
    api_key: str


class UserOutput(UserCreate):
    api_key: str
