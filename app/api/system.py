from fastapi import APIRouter, Body, Depends

from .. import crud
from ..core.params import LANG_HEADER, WEEK_ID_PATH
from ..core.week_ids import expand_week_id, validate_week_id_age
from ..dependencies.auth import admin_required, user_required
from ..models.deactivated_weeks import DeactivatedWeekCreate
from ..models.extras import Message, WeekId
from ..models.settings import SettingsIO, SettingsUpdateIO

router = APIRouter()


@router.patch(
    "/settings",
    response_model=SettingsIO,
    dependencies=[Depends(admin_required)],
    operation_id="editSystemSettings",
    summary="Edit system settings",
    responses={
        400: {"model": Message, "description": "Request body is not a valid JSON"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "Admin access required"},
    },
)
async def edit_settings(
    settings: SettingsUpdateIO = Body(...), lang: str = LANG_HEADER
):
    """Edit the system settings."""
    return crud.settings.map_to_io(
        await crud.settings.update(lang=lang, obj_in=settings)
    )


@router.get(
    "/settings",
    response_model=SettingsIO,
    dependencies=[Depends(admin_required)],
    operation_id="getSystemSettings",
    summary="Get system settings",
    responses={
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "Admin access required"},
    },
)
async def get_settings(lang: str = LANG_HEADER):
    """Get the system settings."""
    settings = await crud.settings.get(lang=lang)
    if settings is None:
        settings = await crud.settings.create_default(lang=lang)
    return crud.settings.map_to_io(settings)


@router.post(
    "/deactivate/{week_id}",
    dependencies=[Depends(admin_required)],
    operation_id="deactivateWeekSystem",
    response_model=WeekId,
    responses={
        400: {"model": Message, "description": "Chore types exist for week"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "Admin access required"},
        409: {"model": Message, "description": "Week is already deactivated"},
    },
    summary="Deactivate chore creation",
)
async def deactivate_week(week_id: str = WEEK_ID_PATH):
    """Deactivates the chore creation on a specific week for all users."""
    week_id = expand_week_id(week_id)
    await validate_week_id_age(week_id, equals=True)
    obj_in = DeactivatedWeekCreate(week_id=week_id, user_id=None)
    await crud.deactivated_weeks.create(obj_in=obj_in)
    return WeekId(week_id=week_id)


@router.post(
    "/reactivate/{week_id}",
    dependencies=[Depends(admin_required)],
    operation_id="reactivateWeekSystem",
    response_model=WeekId,
    responses={
        400: {"model": Message, "description": "Week is not deactivated"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "Admin access required"},
    },
    summary="Reactivate chore creation",
)
async def reactivate_week(week_id: str = WEEK_ID_PATH, lang: str = LANG_HEADER):
    """Reactivates the chore creation on a specific week for all users."""
    week_id = expand_week_id(week_id)
    obj_in = DeactivatedWeekCreate(week_id=week_id, user_id=None)
    await crud.deactivated_weeks.delete(id=obj_in.compute_id(), lang=lang)
    return WeekId(week_id=week_id)


@router.get(
    "/deactivate-calendar",
    dependencies=[Depends(user_required)],
    operation_id="listDeactivatedWeeksSystem",
    response_model=list[WeekId],
    responses={
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
    },
    summary="List deactivated weeks",
)
async def list_deactivated_weeks():
    """Lists the weeks that are deactivated for chore creation."""
    result = await crud.deactivated_weeks.get_multi()
    return [WeekId(week_id=week.week_id) for week in result if week.user_id is None]
