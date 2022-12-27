from fastapi import APIRouter, Depends

from .. import crud
from ..dependencies.auth import APIKeySecurity, get_user_id_from_api_key, user_required
from ..dependencies.pages import PaginationParams, pagination_params
from ..models.extras import Message
from ..models.transfer import Transfer, TransferCreate

router = APIRouter()


@router.post(
    "",
    operation_id="startTransfer",
    response_model=Transfer,
    dependencies=[Depends(user_required)],
    responses={
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
    },
)
async def start_transfer(
    transfer: TransferCreate,
    user_id: str = Depends(get_user_id_from_api_key),
    x_token: str = APIKeySecurity,
):
    return await crud.transfers.create(
        obj_in=transfer, user_id=user_id, x_token=x_token
    )


@router.get("/{transfer_id}", operation_id="getTransfer", response_model=Transfer)
async def get_transfer(transfer_id: int):
    return await crud.transfers.get_or_404(id=transfer_id)


@router.get("", operation_id="listTransfers", response_model=list[Transfer])
async def list_transfers(pagination: PaginationParams = Depends(pagination_params)):
    return await crud.transfers.get_multi(
        page=pagination.page, per_page=pagination.per_page
    )


@router.post(
    "/{transfer_id}/accept", operation_id="acceptTransfer", response_model=Transfer
)
async def accept_transfer(transfer_id: int):
    return await crud.transfers.accept(id=transfer_id)


@router.post(
    "/{transfer_id}/reject", operation_id="rejectTransfer", response_model=Transfer
)
async def reject_transfer(transfer_id: int):
    return await crud.transfers.reject(id=transfer_id)
