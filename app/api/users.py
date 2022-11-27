from fastapi import APIRouter, Body, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from .. import crud
from ..dependencies.db import get_db
from ..dependencies.auth import admin_required
from ..models import User, UserCreate

router = APIRouter()


@router.post("", response_model=User, dependencies=[Depends(admin_required)], operation_id="createUser")
async def create_user(db: AsyncSession = Depends(get_db), user: UserCreate = Body()):
    return await crud.user.create(db, obj_in=user)


@router.get("/{user_id}", response_model=User, operation_id="getUser")
async def get_user(user_id: str, db: AsyncSession = Depends(get_db)):
    return await crud.user.get(db, id=user_id)


@router.get("", response_model=list[User], operation_id="listUsers")
async def list_users(db: AsyncSession = Depends(get_db)):
    return await crud.user.get_multi(db)
