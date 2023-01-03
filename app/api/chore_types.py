from fastapi import APIRouter, Body, Depends

from .. import crud
from ..core.params import LANG_HEADER
from ..dependencies.auth import admin_required, user_required
from ..models.chore_type import ChoreType
from ..models.extras import Message

router = APIRouter()


@router.post(
    "",
    response_model=ChoreType,
    dependencies=[Depends(admin_required)],
    operation_id="createChoreType",
    responses={
        400: {
            "model": Message,
            "description": "Can't use the 'me' keyword with the admin API key",
        },
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "Admin access required"},
        409: {"model": Message, "description": "ChoreType already exists"},
    },
)
async def create_chore_type(chore_type: ChoreType = Body(...), lang: str = LANG_HEADER):
    return await crud.chore_types.create(lang=lang, obj_in=chore_type)


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
async def get_chore_type(chore_type_id: str, lang: str = LANG_HEADER):
    return await crud.chore_types.get_or_404(lang=lang, id=chore_type_id)


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


@router.delete(
    "/{chore_type_id}",
    status_code=204,
    dependencies=[Depends(admin_required)],
    operation_id="deleteChoreType",
    responses={
        400: {
            "model": Message,
            "description": "Chore type has active chores or unbalanced tickets",
        },
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "Admin access required"},
        404: {"model": Message, "description": "Chore type not found"},
    },
)
async def delete_chore_type(chore_type_id: str, lang: str = LANG_HEADER):
    """Deletes a chore type. Note that the system setting `assignment_order` will
    be reset after this operation.

    This endpoint will throw a 400 error in the following cases:

    * Chore type has active chores (not completed)
    * Chore type has unbalanced tickets

    """
    return await crud.chore_types.delete(id=chore_type_id, lang=lang)
