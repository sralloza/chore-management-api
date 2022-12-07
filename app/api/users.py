from fastapi import APIRouter, Body, Depends, Header, HTTPException

from .. import crud
from ..core.constants import WEEK_ID_PATH, USER_ID_PATH
from ..core.users import expand_user_id
from ..core.week_ids import expand_week_id, validate_week_id_age
from ..dependencies.auth import admin_required, user_required_me_path
from ..models.deactivated_weeks import DeactivatedWeekCreate
from ..models.extras import Message, WeekId
from ..models.user import UserCreate, UserOutput, UserSimple

router = APIRouter()


@router.post(
    "",
    response_model=UserOutput,
    dependencies=[Depends(admin_required)],
    operation_id="createUser",
    summary="Register new user",
    responses={
        400: {"model": Message, "description": "Request body is not a valid JSON"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "Admin access required"},
        409: {
            "model": Message,
            "description": "User already exists",
        },
    },
)
async def create_user(user: UserCreate = Body()):
    """Register a new user. Note that the system setting `assignment_order` will be
    reset after this operation."""
    return await crud.user.create(obj_in=user)


@router.get(
    "/{user_id}",
    dependencies=[Depends(user_required_me_path)],
    operation_id="getUser",
    response_model=UserSimple,
    responses={
        400: {
            "model": Message,
            "description": "Can't use the 'me' keyword with the admin API key",
        },
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
        404: {"model": Message, "description": "User not found"},
    },
)
async def get_user(user_id: str = USER_ID_PATH, x_token: str = Header(None)):
    """Get user by id. Any user can access their own data using the
    special keyword `me`."""
    return await crud.user.get_or_404_me_safe(id=user_id, api_key=x_token)


@router.get(
    "",
    dependencies=[Depends(admin_required)],
    response_model=list[UserOutput],
    operation_id="listUsers",
    responses={
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "Admin required"},
    },
)
async def list_users():
    """List all users."""
    return await crud.user.get_multi()


@router.delete(
    "/{user_id}", dependencies=[Depends(admin_required)], operation_id="deleteUser"
)
async def delete_user(user_id: str):
    raise HTTPException(status_code=501, detail="Not implemented")


@router.post(
    "/{user_id}/deactivate/{week_id}",
    dependencies=[Depends(user_required_me_path)],
    operation_id="deactivateWeekUser",
    response_model=WeekId,
    responses={
        400: {"model": Message, "description": "Chore types exist for week"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
        404: {"model": Message, "description": "User not found"},
        409: {"model": Message, "description": "Week is already deactivated"},
    },
    summary="Deactivate chore creation",
)
async def deactivate_week(
    user_id: str = USER_ID_PATH,
    week_id: str = WEEK_ID_PATH,
    x_token: str = Header(None),
):
    """Deactivates the chore creation on a specific week for just a specific user."""
    user_id = await expand_user_id(user_id, x_token)
    await crud.user.get_or_404(id=user_id)

    week_id = expand_week_id(week_id)
    await validate_week_id_age(week_id, equals=True)

    obj_in = DeactivatedWeekCreate(week_id=week_id, user_id=user_id)
    await crud.deactivated_weeks.create(obj_in=obj_in)
    return WeekId(week_id=week_id)
