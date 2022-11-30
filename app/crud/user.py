import sqlalchemy as sa

from .. import crud
from ..db import tables
from ..db.session import database
from ..models.user import User, UserCreate, UserCreateInner
from .base import CRUDBase

UserUpdate = UserCreate


class CRUDUser(CRUDBase[User, UserCreateInner, UserUpdate, str]):
    async def create(self, *, obj_in: UserCreate) -> User:
        user = UserCreateInner(**obj_in.dict())
        result = await super().create(obj_in=user)
        await crud.settings.reset_assignment_order()
        return result

    async def get_or_404_me_safe(self, *, api_key: str, id: str) -> User:
        if id == "me":
            query = self.table.select().where(self.table.c.api_key == api_key)
            db_user = await database.fetch_one(query)
            if not db_user:
                self.throw_404_exception(id)
            return self.model(**db_user)
        else:
            return await self.get_or_404(id=id)

    async def get_user_ids(self) -> list[str]:
        query = sa.select([self.table.c.id]).order_by(self.table.c.created_at)
        result = await database.fetch_all(query)
        return [x["id"] for x in result]


user = CRUDUser(User, tables.user)
