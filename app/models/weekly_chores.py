from pydantic import BaseModel, Field


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
    type: str = Field(description="Chore type identifier", example="clean-dishes")
    week_id: str = Field(description="Week identifier", example="2022.01")


class WeeklyChores(BaseModel):
    chores: list[WeeklyChore] = Field(
        description="List of individual chores for the week"
    )
    week_id: str = Field(description="Week identifier", example="2022.01")
