from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from ..middlewares.db import get_db

router = APIRouter()

@router.post("")
def create_user(db: AsyncSession = Depends(get_db)):
    return {"message": "Create user"}
