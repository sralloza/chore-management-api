from fastapi import APIRouter

from .system import router as system_router
from .users import router as users_router

router = APIRouter()
router.include_router(users_router, prefix="/users", tags=["users"])
router.include_router(system_router, prefix="/system", tags=["system"])
