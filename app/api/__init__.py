from fastapi import APIRouter

from . import (
    chore_types,
    chores,
    system,
    tickets,
    transfers,
    users,
    week_ids,
    weekly_chores,
)

router = APIRouter()

router.include_router(chore_types.router, prefix="/chore-types", tags=["Chore Types"])
router.include_router(chores.router, prefix="/chores", tags=["Chores"])
router.include_router(system.router, prefix="/system", tags=["System"])
router.include_router(tickets.router, prefix="/tickets", tags=["Tickets"])
router.include_router(transfers.router, prefix="/transfers", tags=["Transfers"])
router.include_router(users.router, prefix="/users", tags=["Users"])
router.include_router(week_ids.router, prefix="/week-id", tags=["Week ID"])
router.include_router(
    weekly_chores.router, prefix="/weekly-chores", tags=["Weekly Chores"]
)
