from pydantic import BaseModel

from .common import WEEK_ID_FIELD


class DeactivatedWeekCreate(BaseModel):
    week_id: str = WEEK_ID_FIELD
    user_id: str | None

    def compute_id(self) -> str:
        if self.user_id is None:
            return self.week_id
        return f"{self.week_id}#{self.user_id}"


class DeactivatedWeek(DeactivatedWeekCreate):
    id: str
