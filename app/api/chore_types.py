from fastapi import APIRouter, Body, Depends

from .. import crud
from ..dependencies.auth import admin_required, user_required
from ..models import ChoreType, Message

router = APIRouter()


@router.post(
    "",
    response_model=ChoreType,
    dependencies=[Depends(admin_required)],
    operation_id="createChoreType",
)
async def create_chore_type(chore_type: ChoreType = Body(...)):
    return await crud.chore_types.create(obj_in=chore_type)


@router.get(
    "/{chore_type_id}",
    response_model=ChoreType,
    operation_id="getChoreType",
    dependencies=[Depends(user_required)],
    responses={
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
        404: {"model": Message, "description": "Chore type not found"},
    },
)
async def get_chore_type(chore_type_id: str):
    return await crud.chore_types.get_or_404(id=chore_type_id)


@router.get(
    "",
    response_model=list[ChoreType],
    dependencies=[Depends(user_required)],
    operation_id="listChoreTypes",
    responses={
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
    },
)
async def get_chore_types():
    return await crud.chore_types.get_multi()
