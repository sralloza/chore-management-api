from fastapi import APIRouter

from .users import router as users_router
from .system import router as system_router

router = APIRouter()
router.include_router(users_router, prefix="/users", tags=["users"])
router.include_router(system_router, prefix="/system", tags=["system"])
