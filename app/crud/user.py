import sqlalchemy as sa

from .. import crud
from ..core.users import expand_user_id
from ..db import tables
from ..db.session import database
from ..models.user import User, UserCreate, UserCreateInner
from .base import CRUDBase

UserUpdate = UserCreate


class CRUDUser(CRUDBase[User, UserCreateInner, UserUpdate, str]):
    async def create(self, *, lang: str, obj_in: UserCreate) -> User:
        user = UserCreateInner(**obj_in.dict())
        result = await super().create(lang=lang, obj_in=user)
        await crud.settings.reset_assignment_order(lang=lang)
        await crud.tickets.create_tickets_for_new_user(lang=lang, user_id=result.id)
        return result

    async def get_or_404_me_safe(self, *, lang: str, api_key: str, id: str) -> User:
        id = await expand_user_id(id, api_key)
        return await super().get_or_404(lang=lang, id=id)

    async def get_user_ids(self) -> list[str]:
        query = sa.select([self.table.c.id]).order_by(self.table.c.created_at)
        result = await database.fetch_all(query)
        return [x["id"] for x in result]


user = CRUDUser(User, tables.user)
