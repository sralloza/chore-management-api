from fastapi import APIRouter, Body, Depends

from .. import crud
from ..core.params import LANG_HEADER, USER_ID_PATH, WEEK_ID_PATH
from ..core.users import expand_user_id
from ..core.week_ids import expand_week_id, validate_week_id_age
from ..dependencies.auth import APIKeySecurity, admin_required, user_required_me_path
from ..models.deactivated_weeks import DeactivatedWeekCreate
from ..models.extras import Message, WeekId
from ..models.user import UserCreate, UserIdentifier, UserOutput, UserSimple

router = APIRouter()


@router.post(
    "",
    response_model=UserIdentifier,
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
async def create_user(user: UserCreate = Body(), lang: str = LANG_HEADER):
    """Register a new user. Note that the system setting `assignment_order` will be
    reset after this operation."""
    return await crud.user.create(lang=lang, obj_in=user)


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
async def get_user(
    user_id: str = USER_ID_PATH, x_token: str = APIKeySecurity, lang: str = LANG_HEADER
):
    """Get user by id. Any user can access their own data using the
    special keyword `me`."""
    return await crud.user.get_or_404_me_safe(lang=lang, id=user_id, api_key=x_token)


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
    "/{user_id}",
    dependencies=[Depends(admin_required)],
    operation_id="deleteUser",
    status_code=204,
    responses={
        400: {"model": Message, "description": "Chores exist for week"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
        404: {"model": Message, "description": "User not found"},
        409: {"model": Message, "description": "Week is already deactivated"},
    },
)
async def delete_user(user_id: str, lang: str = LANG_HEADER):
    """Deletes a user. Note that the system setting `assignment_order` will be reset
    after this operation.

    This endpoint will throw a 400 error in the following cases:

    * User has active chores (not completed)
    * User has unbalanced tickets

    """
    await crud.user.delete(lang=lang, id=user_id)


@router.post(
    "/{user_id}/deactivate/{week_id}",
    dependencies=[Depends(user_required_me_path)],
    operation_id="deactivateWeekUser",
    response_model=WeekId,
    responses={
        400: {"model": Message, "description": "Chores exist for week"},
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
    x_token: str = APIKeySecurity,
    lang: str = LANG_HEADER,
):
    """Deactivates the chore creation on a specific week for just a specific user."""
    user_id = await expand_user_id(user_id, x_token, lang)
    await crud.user.get_or_404(lang=lang, id=user_id)

    week_id = expand_week_id(week_id)
    await validate_week_id_age(week_id, lang, equals=True)

    obj_in = DeactivatedWeekCreate(week_id=week_id, user_id=user_id)
    await crud.deactivated_weeks.create(obj_in=obj_in, lang=lang)
    return WeekId(week_id=week_id)


@router.post(
    "/{user_id}/reactivate/{week_id}",
    dependencies=[Depends(user_required_me_path)],
    operation_id="reactivateWeekUser",
    response_model=WeekId,
    responses={
        400: {"model": Message, "description": "Chores exist for week"},
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
        404: {"model": Message, "description": "User not found"},
        409: {"model": Message, "description": "Week is already activated"},
    },
    summary="Reactivate chore creation",
)
async def reactivate_week(
    user_id: str = USER_ID_PATH,
    week_id: str = WEEK_ID_PATH,
    x_token: str = APIKeySecurity,
    lang: str = LANG_HEADER,
):
    """Reactivates the chore creation on a specific week for just a specific user."""
    user_id = await expand_user_id(user_id, x_token, lang)
    await crud.user.get_or_404(lang=lang, id=user_id)

    week_id = expand_week_id(week_id)
    await validate_week_id_age(week_id, lang, equals=True)

    obj = DeactivatedWeekCreate(week_id=week_id, user_id=user_id)

    if not await crud.deactivated_weeks.get(id=obj.compute_id()):
        crud.deactivated_weeks.throw_conflict_exception(
            lang=lang, id=obj.compute_id(), action="activated"
        )

    await crud.deactivated_weeks.delete(lang=lang, id=obj.compute_id())

    return WeekId(week_id=week_id)
