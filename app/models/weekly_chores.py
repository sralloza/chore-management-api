from pydantic import BaseModel, Field

from .common import CHORE_TYPE_ID_FIELD, WEEK_ID_FIELD


class WeeklyChore(BaseModel):
    assigned_ids: list[str] = Field(
        description="List of user IDs assigned to the chore",
        example=["user-1", "user-2"],
    )
    assigned_usernames: list[str] = Field(
        description="List of usernames assigned to the chore",
        example=["username-1", "username-2"],
    )
    done: bool = Field(description="Whether the chore has been completed", example=True)
    chore_type_id: str = CHORE_TYPE_ID_FIELD


class WeeklyChores(BaseModel):
    chores: list[WeeklyChore] = Field(
        description="List of individual chores for the week"
    )
    week_id: str = WEEK_ID_FIELD
