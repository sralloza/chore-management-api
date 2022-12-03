from pydantic import BaseModel


class WeeklyChore(BaseModel):
    assigned_ids: list[str]
    assigned_usernames: list[str]
    done: bool
    type: str
    week_id: str


class WeeklyChores(BaseModel):
    chores: list[WeeklyChore]
    week_id: str
