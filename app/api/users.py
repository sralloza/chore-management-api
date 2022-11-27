from fastapi import APIRouter, Body, Depends, Header
from sqlalchemy.ext.asyncio import AsyncSession

from .. import crud
from ..dependencies.auth import admin_required, user_required_me_path
from ..dependencies.db import get_db
from ..models import Message, User, UserCreate, UserSimple

router = APIRouter()


@router.post(
    "",
    response_model=User,
    dependencies=[Depends(admin_required)],
    operation_id="createUser",
    summary="Register new user",
    responses={
        400: {"model": Message, "description": "Request body is not a valid JSON"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "Admin access required"},
        409: {
            "model": Message,
            "description": "User already exists",
        },
    },
)
async def create_user(db: AsyncSession = Depends(get_db), user: UserCreate = Body()):
    """Register a new user. Note that the system setting `assignment_order` will be
    reset after this operation."""
    return await crud.user.create(db, obj_in=user)


@router.get(
    "/{user_id}",
    dependencies=[Depends(user_required_me_path)],
    operation_id="getUser",
    response_model=UserSimple,
    responses={
        400: {
            "model": Message,
            "description": "Can't use the 'me' keyword with the admin API key",
        },
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
        404: {"model": Message, "description": "User not found"},
    },
)
async def get_user(
    user_id: str, db: AsyncSession = Depends(get_db), x_token: str = Header(None)
):
    return await crud.user.get_or_404_me_safe(db, id=user_id, api_key=x_token)


@router.get("", response_model=list[User], operation_id="listUsers")
async def list_users(db: AsyncSession = Depends(get_db)):
    return await crud.user.get_multi(db)
