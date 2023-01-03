import time
from uuid import uuid4

from pydantic import BaseModel, Field, validator

from .common import USER_ID_FIELD, USER_USERNAME_FIELD


class UserBaseID(BaseModel):
    id: str = USER_ID_FIELD


class UserIdentifier(UserBaseID):
    pass


class UserBase(UserBaseID):
    username: str = USER_USERNAME_FIELD
    id: str = USER_ID_FIELD


class UserCreate(UserBase):
    @validator("id", pre=True)
    def check_blacklist(cls, v):  # noqa: N805
        if isinstance(v, str) and v.lower() == "me":
            raise ValueError("Forbidden user ID: me")
        return v


class UserSimple(UserBase):
    pass


class UserCreateInner(UserBase):
    api_key: str = Field(max_length=36, default_factory=lambda: str(uuid4()))
    created_at: int = Field(default_factory=lambda: int(time.time() * 10**6))


class User(UserBase):
    api_key: str


class UserOutput(UserBase):
    api_key: str
