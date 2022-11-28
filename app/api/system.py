from fastapi import APIRouter, Body, Depends

from .. import crud
from ..dependencies.auth import admin_required
from ..models import SettingsIO, SettingsUpdate, SettingsUpdateIO

router = APIRouter()


@router.patch(
    "/settings",
    response_model=SettingsIO,
    dependencies=[Depends(admin_required)],
    operation_id="editSystemSettings",
)
async def edit_settings(settings: SettingsUpdateIO = Body(...)):
    update_data = settings.dict()
    assignment_order = update_data.pop("assignment_order", None)
    if assignment_order:
        update_data["assignment_order"] = ",".join(assignment_order)
    return crud.settings.map_to_io(
        await crud.settings.update(obj_in=SettingsUpdate(**update_data))
    )


@router.get(
    "/settings",
    response_model=SettingsIO,
    dependencies=[Depends(admin_required)],
    operation_id="getSystemSettings",
)
async def get_settings():
    return crud.settings.map_to_io(await crud.settings.get_or_404())
