from fastapi import APIRouter, Depends

from .. import crud
from ..core.params import LANG_HEADER
from ..dependencies.auth import APIKeySecurity, get_user_id_from_api_key, user_required
from ..dependencies.pages import PaginationParams, pagination_params
from ..models.extras import Message
from ..models.transfer import Transfer, TransferCreate

router = APIRouter()


@router.post(
    "",
    dependencies=[Depends(user_required)],
    operation_id="startTransfer",
    response_model=Transfer,
    responses={
        400: {"model": Message, "description": "Bad request"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
    },
    summary="Start transfer",
)
async def start_transfer(
    transfer: TransferCreate,
    user_id: str = Depends(get_user_id_from_api_key),
    x_token: str = APIKeySecurity,
    lang: str = LANG_HEADER,
):
    """Start a chore transfer."""
    return await crud.transfers.create(
        lang=lang, obj_in=transfer, user_id=user_id, x_token=x_token
    )


@router.get(
    "/{transfer_id}",
    dependencies=[Depends(user_required)],
    operation_id="getTransfer",
    response_model=Transfer,
    responses={
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
        404: {"model": Message, "description": "Transfer not found"},
    },
    summary="Get transfer",
)
async def get_transfer(transfer_id: int, lang: str = LANG_HEADER):
    """Get a chore transfer by its id."""
    return await crud.transfers.get_or_404(lang=lang, id=transfer_id)


@router.get(
    "",
    dependencies=[Depends(user_required)],
    operation_id="listTransfers",
    response_model=list[Transfer],
    responses={
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
    },
    summary="List transfers",
)
async def list_transfers(pagination: PaginationParams = Depends(pagination_params)):
    """List chore transfers."""
    return await crud.transfers.get_multi(
        page=pagination.page, per_page=pagination.per_page
    )


@router.post(
    "/{transfer_id}/accept",
    dependencies=[Depends(user_required)],
    operation_id="acceptTransfer",
    response_model=Transfer,
    responses={
        400: {"model": Message, "description": "Transfer already completed"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
        404: {"model": Message, "description": "Transfer not found"},
    },
    summary="Accept transfer",
)
async def accept_transfer(
    transfer_id: int,
    user_id: str = Depends(get_user_id_from_api_key),
    lang: str = LANG_HEADER,
):
    """Accept a chore transfer."""
    return await crud.transfers.accept(lang=lang, id=transfer_id, user_id=user_id)


@router.post(
    "/{transfer_id}/reject",
    dependencies=[Depends(user_required)],
    operation_id="rejectTransfer",
    response_model=Transfer,
    responses={
        400: {"model": Message, "description": "Transfer already completed"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
        404: {"model": Message, "description": "Transfer not found"},
    },
    summary="Reject transfer",
)
async def reject_transfer(
    transfer_id: int,
    user_id: str = Depends(get_user_id_from_api_key),
    lang: str = LANG_HEADER,
):
    """Reject a chore transfer."""
    return await crud.transfers.reject(lang=lang, id=transfer_id, user_id=user_id)
