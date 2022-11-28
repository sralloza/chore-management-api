from enum import Enum

from pydantic import BaseModel, Field


class RotationSign(Enum):
    positive = "positive"
    negative = "negative"


class SettingsBase(BaseModel):
    rotation_sign: RotationSign
    assignment_order: str = Field(max_length=2048)


class Settings(SettingsBase):
    id: str = Field(max_length=36)


class SettingsUpdate(SettingsBase):
    rotation_sign: RotationSign | None = None
    assignment_order: str | None = None


class SettingsUpdateIO(SettingsUpdate):
    assignment_order: list[str]


class SettingsIO(SettingsBase):
    assignment_order: list[str]


class SettingsCreate(SettingsUpdate):
    id: str = Field(max_length=36)
    rotation_sign: RotationSign = RotationSign.positive
