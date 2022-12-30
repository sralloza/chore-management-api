from datetime import datetime

import i18n
from fastapi import HTTPException

from .. import crud
from ..core.users import expand_user_id
from ..core.week_ids import expand_week_id
from ..db import tables
from ..models.transfer import Transfer, TransferCreate, TransferCreateInner
from .base import CRUDBase


def validate_user_id(expected: str, actual: str | None, action: str, lang: str):
    if actual is not None and expected != actual:
        action = i18n.t(f"actions.{action}", locale=lang)
        detail = i18n.t(
            "crud.forbidden.transfer_other_user", locale=lang, action=action
        )
        raise HTTPException(403, detail)


class CRUDTransfers(CRUDBase[Transfer, TransferCreateInner, Transfer, int]):
    spanish_model_femenine = True

    def raise_transfer_completed_exception(self, lang: str):
        detail = i18n.t("crud.bad_request.transfer_completed", locale=lang)
        raise HTTPException(400, detail)

    async def create(
        self,
        *,
        lang: str,
        x_token: str,
        obj_in: TransferCreate,
        check_409: bool = True,
        user_id: str | None = None,
    ) -> Transfer:
        obj_in.user_id_from = await expand_user_id(obj_in.user_id_from, x_token, lang)
        obj_in.week_id = expand_week_id(obj_in.week_id)
        validate_user_id(obj_in.user_id_from, user_id, "create", lang)
        transfers = await crud.transfers.get_multi(
            chore_type_id=obj_in.chore_type_id,
            week_id=obj_in.week_id,
            user_id_from=obj_in.user_id_from,
            completed=False,
        )
        if transfers:
            raise HTTPException(
                400, i18n.t("crud.bad_request.transfer_multiple_users", locale=lang)
            )

        if obj_in.user_id_from == obj_in.user_id_to:
            detail = i18n.t("crud.bad_request.transfer_to_self", locale=lang)
            raise HTTPException(400, detail)

        if not await crud.user.get(id=obj_in.user_id_from):
            raise HTTPException(
                400, crud.user.get_not_found_detail(lang, obj_in.user_id_from)
            )

        if not await crud.user.get(id=obj_in.user_id_to):
            raise HTTPException(
                400, crud.user.get_not_found_detail(lang, obj_in.user_id_to)
            )
        if not await crud.chore_types.get(id=obj_in.chore_type_id):
            raise HTTPException(
                400, crud.chore_types.get_not_found_detail(lang, obj_in.chore_type_id)
            )

        chores = await crud.chores.get_multi(
            chore_type_id=obj_in.chore_type_id,
            week_id=obj_in.week_id,
            user_id=obj_in.user_id_from,
        )
        if not chores:
            detail = i18n.t(
                "crud.bad_request.transfer_no_chores",
                locale=lang,
                chore_type_id=obj_in.chore_type_id,
                week_id=obj_in.week_id,
                user_id=obj_in.user_id_from,
            )
            raise HTTPException(400, detail)

        obj_in_inner = TransferCreateInner(**obj_in.dict())
        return await super().create(lang=lang, obj_in=obj_in_inner, check_409=check_409)

    async def accept(self, *, lang: str, id: int, user_id: str | None) -> Transfer:
        transfer = await self.get_or_404(lang=lang, id=id)
        validate_user_id(transfer.user_id_to, user_id, "accept", lang)

        if transfer.completed:
            self.raise_transfer_completed_exception(lang)

        chores = await crud.chores.get_multi(
            chore_type_id=transfer.chore_type_id,
            week_id=transfer.week_id,
            user_id=transfer.user_id_from,
        )
        if len(chores) > 1:
            raise ValueError("More than one chore of the same type for the same week")

        chore = chores[0]
        chore.user_id = transfer.user_id_to
        await crud.chores.update(id=chore.id, lang=lang, obj_in=chore)

        await crud.tickets.transfer_ticket(
            lang=lang,
            user_id_from=transfer.user_id_from,
            user_id_to=transfer.user_id_to,
            chore_type_id=transfer.chore_type_id,
        )

        transfer.accepted = True
        transfer.completed = True
        transfer.completed_at = datetime.now()
        await self.update(id=id, lang=lang, obj_in=transfer)
        return await self.get_or_404(lang=lang, id=id)

    async def reject(self, *, lang: str, id: int, user_id: str | None) -> Transfer:
        transfer = await self.get_or_404(lang=lang, id=id)
        validate_user_id(transfer.user_id_to, user_id, "reject", lang)

        if transfer.completed:
            self.raise_transfer_completed_exception(lang)

        transfer.accepted = False
        transfer.completed = True
        transfer.completed_at = datetime.now()
        await self.update(id=id, lang=lang, obj_in=transfer)
        return await self.get_or_404(lang=lang, id=id)


transfers = CRUDTransfers(Transfer, tables.transfer)
