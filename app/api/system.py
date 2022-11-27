from fastapi import APIRouter, Body, Depends
from sqlmodel import Session

from .. import crud
from ..dependencies.auth import admin_required
from ..dependencies.db import get_db
from ..models import SettingsIO, SettingsUpdateIO, SettingsUpdate

router = APIRouter()


@router.patch(
    "/settings",
    response_model=SettingsIO,
    dependencies=[Depends(admin_required)],
    operation_id="editSystemSettings",
)
def edit_settings(
    db: Session = Depends(get_db), settings: SettingsUpdateIO = Body(...)
):
    db_settings = crud.settings.get_or_404(db)
    update_data = settings.dict()
    assignment_order = update_data.pop("assignment_order", None)
    if assignment_order:
        update_data["assignment_order"] = ",".join(assignment_order)
    update = SettingsUpdate(**update_data)
    return crud.settings.map_to_io(
        crud.settings.update(db, db_obj=db_settings, obj_in=update)
    )


@router.get(
    "/settings",
    response_model=SettingsIO,
    dependencies=[Depends(admin_required)],
    operation_id="getSystemSettings",
)
def get_settings(db: Session = Depends(get_db)):
    return crud.settings.map_to_io(crud.settings.get_or_404(db))
