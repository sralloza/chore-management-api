from uuid import uuid4

from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select

from ..models import User, UserCreate
from .base import CRUDBase

UserUpdate = UserCreate


class CRUDUser(CRUDBase[User, User, UserUpdate, str]):
    async def create(self, db: AsyncSession, *, obj_in: UserCreate) -> User:
        user = User(**obj_in.dict(), api_key=str(uuid4()))
        return await super().create(db, obj_in=user)

    async def get_or_404_me_safe(self, db: AsyncSession, *, api_key: str, id: str) -> User:
        if id == "me":
            result = await db.execute(select(self.model).where(self.model.api_key == api_key))
            db_user = result.scalars().first()
            if not db_user:
                self.throw_404_exception(id)
            return db_user
        else:
            return await self.get_or_404(db, id=id)



user = CRUDUser(User)
