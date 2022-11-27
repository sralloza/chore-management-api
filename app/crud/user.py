from uuid import uuid4

from sqlalchemy.ext.asyncio import AsyncSession

from ..models import User, UserCreate
from .base import CRUDBase

UserUpdate = UserCreate


class CRUDUser(CRUDBase[User, User, UserUpdate, str]):
    async def create(self, db: AsyncSession, *, obj_in: UserCreate) -> User:
        user = User(**obj_in.dict(), api_key=str(uuid4()))
        return await super().create(db, obj_in=user)


user = CRUDUser(User)
