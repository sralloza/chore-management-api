from sqlmodel import Field, SQLModel
from pydantic import BaseModel
from typing import Literal
from enum import Enum


class RotationSign(Enum):
    positive = "positive"
    negative = "negative"


class SettingsBase(SQLModel):
    rotation_sign: RotationSign
    assignment_order: str = Field(max_length=2048)


class Settings(SettingsBase, table=True):
    id: str = Field(primary_key=True, max_length=36)


class SettingsUpdate(SettingsBase):
    rotation_sign: RotationSign | None = None
    assignment_order: str | None = None


class SettingsUpdateIO(SettingsUpdate):
    assignment_order: list[str]


class SettingsIO(SettingsBase):
    assignment_order: list[str]


class SettingsCreate(SettingsUpdate):
    id: str = Field(primary_key=True, max_length=36)
    rotation_sign: RotationSign = RotationSign.positive
