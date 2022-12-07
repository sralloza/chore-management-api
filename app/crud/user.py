import sqlalchemy as sa

from .. import crud
from ..db import tables
from ..db.session import database
from ..models.user import User, UserCreate, UserCreateInner
from .base import CRUDBase
from ..core.users import expand_user_id

UserUpdate = UserCreate


class CRUDUser(CRUDBase[User, UserCreateInner, UserUpdate, str]):
    async def create(self, *, obj_in: UserCreate) -> User:
        user = UserCreateInner(**obj_in.dict())
        result = await super().create(obj_in=user)
        await crud.settings.reset_assignment_order()
        await crud.tickets.create_tickets_for_new_user(user_id=result.id)
        return result

    async def get_or_404_me_safe(self, *, api_key: str, id: str) -> User:
        id = await expand_user_id(id, api_key)
        return await super().get_or_404(id=id)

    async def get_user_ids(self) -> list[str]:
        query = sa.select([self.table.c.id]).order_by(self.table.c.created_at)
        result = await database.fetch_all(query)
        return [x["id"] for x in result]


user = CRUDUser(User, tables.user)
