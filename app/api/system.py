from fastapi import APIRouter, Body, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from .. import crud
from ..dependencies.auth import admin_required
from ..dependencies.db import get_db
from ..models import User, UserCreate

router = APIRouter()


@router.patch("/settings", response_model=User, dependencies=[Depends(admin_required)])
async def create_user(db: AsyncSession = Depends(get_db), user: UserCreate = Body(...)):
    return await crud.user.create(db, obj_in=user)
