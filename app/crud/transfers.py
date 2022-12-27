from datetime import datetime

from fastapi import HTTPException

from .. import crud
from ..core.users import expand_user_id
from ..core.week_ids import expand_week_id
from ..db import tables
from ..models.transfer import Transfer, TransferCreate, TransferCreateInner
from .base import CRUDBase


def validate_user_id(expected: str, actual: str | None, action: str):
    if actual is not None and expected != actual:
        raise HTTPException(403, f"You cannot {action} a transfer for another user")


class CRUDTransfers(CRUDBase[Transfer, TransferCreateInner, Transfer, int]):
    async def create(
        self,
        *,
        x_token: str,
        obj_in: TransferCreate,
        check_409: bool = True,
        user_id: str | None = None,
    ) -> Transfer:
        obj_in.user_id_from = await expand_user_id(obj_in.user_id_from, x_token)
        obj_in.week_id = expand_week_id(obj_in.week_id)
        validate_user_id(obj_in.user_id_from, user_id, "create")
        transfers = await crud.transfers.get_multi(
            chore_type_id=obj_in.chore_type_id,
            week_id=obj_in.week_id,
            user_id_from=obj_in.user_id_from,
            completed=False,
        )
        if transfers:
            raise HTTPException(400, "Cannot transfer chore to multiple users")

        if obj_in.user_id_from == obj_in.user_id_to:
            raise HTTPException(400, "Cannot transfer chore to the same user")

        if not await crud.user.get(id=obj_in.user_id_from):
            raise HTTPException(400, f"User {obj_in.user_id_from} does not exist")
        if not await crud.user.get(id=obj_in.user_id_to):
            raise HTTPException(400, f"User {obj_in.user_id_to} does not exist")
        if not await crud.chore_types.get(id=obj_in.chore_type_id):
            raise HTTPException(
                400, f"Chore type with id {obj_in.chore_type_id} does not exist"
            )

        chores = await crud.chores.get_multi(
            chore_type_id=obj_in.chore_type_id,
            week_id=obj_in.week_id,
            user_id=obj_in.user_id_from,
        )
        if not chores:
            raise HTTPException(
                400,
                f"No chores of type {obj_in.chore_type_id} for week "
                f"{obj_in.week_id} assigned to user {obj_in.user_id_from}",
            )

        obj_in_inner = TransferCreateInner(**obj_in.dict())
        return await super().create(obj_in=obj_in_inner, check_409=check_409)

    async def accept(self, id: int, user_id: str | None = None) -> Transfer:
        transfer = await self.get_or_404(id=id)
        if user_id is not None:
            if transfer.user_id_to != user_id:
                raise HTTPException(
                    403, "You cannot accept a transfer for another user"
                )
        transfer.accepted = True
        transfer.completed = True
        transfer.completed_at = datetime.now()
        await self.update(id=id, obj_in=transfer)
        return await self.get_or_404(id=id)

    async def reject(self, id: int, user_id: str | None = None) -> Transfer:
        transfer = await self.get_or_404(id=id)
        if user_id is not None:
            if transfer.user_id_to != user_id:
                raise HTTPException(
                    403, "You cannot accept a transfer for another user"
                )
        transfer.accepted = False
        transfer.completed = True
        transfer.completed_at = datetime.now()
        await self.update(id=id, obj_in=transfer)
        return await self.get_or_404(id=id)


transfers = CRUDTransfers(Transfer, tables.transfer)
