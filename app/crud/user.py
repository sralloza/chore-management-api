import i18n
import sqlalchemy as sa
from fastapi import HTTPException

from .. import crud
from ..core.users import expand_user_id
from ..db import tables
from ..db.session import database
from ..models.user import User, UserCreate, UserCreateInner
from .base import CRUDBase


class CRUDUser(CRUDBase[User, UserCreateInner, UserCreate, str]):
    async def create(self, *, lang: str, obj_in: UserCreate) -> User:
        user = UserCreateInner(**obj_in.dict())
        result = await super().create(lang=lang, obj_in=user)
        await crud.settings.reset_assignment_order()
        await crud.tickets.create_tickets_for_new_user(lang=lang, user_id=result.id)
        return result

    async def delete(self, *, lang: str, id: str):
        chores = await crud.chores.get_multi(user_id=id)
        if any((chore.done is False for chore in chores)):
            detail = i18n.t(
                "crud.bad_request.active_chores",
                locale=lang,
                model=self.get_model_name(lang, lower=True),
            )
            raise HTTPException(400, detail)

        tickets = await crud.tickets.get_multi(user_id=id)
        for ticket in tickets:
            if ticket.tickets != 0:
                detail = i18n.t(
                    "crud.bad_request.unbalanced_tickets",
                    locale=lang,
                    model=self.get_model_name(lang, lower=True),
                )
                raise HTTPException(400, detail)

        for chore in chores:
            await crud.chores.delete(lang=lang, id=chore.id)

        for ticket in tickets:
            await crud.tickets.delete(lang=lang, id=ticket.id)

        await super().delete(lang=lang, id=id)
        await crud.settings.reset_assignment_order()

    async def get_or_404_me_safe(self, *, lang: str, api_key: str, id: str) -> User:
        id = await expand_user_id(id, api_key, lang)
        return await super().get_or_404(lang=lang, id=id)

    async def get_user_ids(self) -> list[str]:
        query = sa.select([self.table.c.id]).order_by(self.table.c.created_at)
        result = await database.fetch_all(query)
        return [x["id"] for x in result]


user = CRUDUser(User, tables.user)
