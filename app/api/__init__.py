from fastapi import APIRouter

from .chore_types import router as chore_types_router
from .system import router as system_router
from .tickets import router as tickets_router
from .users import router as users_router
from .week_ids import router as week_ids_router

router = APIRouter()

router.include_router(chore_types_router, prefix="/chore-types", tags=["Chore Types"])
router.include_router(system_router, prefix="/system", tags=["System"])
router.include_router(users_router, prefix="/users", tags=["Users"])
router.include_router(tickets_router, prefix="/tickets", tags=["Tickets"])
router.include_router(week_ids_router, prefix="/week-id", tags=["Week ID"])
