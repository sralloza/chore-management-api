from fastapi import APIRouter, Depends, Header, Query

from .. import crud
from ..core.constants import WEEK_ID_EXPANDED_REGEX
from ..core.users import expand_user_id
from ..core.week_ids import expand_week_id
from ..dependencies.auth import user_required
from ..models.chore import Chore
from ..models.extras import Message

router = APIRouter()


@router.get(
    "",
    response_model=list[Chore],
    operation_id="listChores",
    dependencies=[Depends(user_required)],
    responses={
        400: {
            "model": Message,
            "description": "Can't use the 'me' keyword with the admin API key",
        },
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
    },
)
async def list_chores(
    chore_type_id: str = Query(None, description="Filter by chore type ID"),
    user_id: str = Query(None, description="Filter by user ID"),
    week_id: str = Query(
        None,
        description="Filter by week ID",
        regex=WEEK_ID_EXPANDED_REGEX,
    ),
    done: bool = Query(None, description="Filter by status"),
    x_token: str = Header(None),
):
    week_id = expand_week_id(week_id)
    user_id = await expand_user_id(user_id, x_token)

    return await crud.chores.get_multi(
        chore_type_id=chore_type_id,
        user_id=user_id,
        week_id=week_id,
        done=done,
    )


@router.post(
    "/{week_id}/type/{chore_type_id}",
    dependencies=[Depends(user_required)],
    operation_id="completeChore",
    status_code=204,
)
async def complete_chore(week_id: str, chore_type_id: str):
    await crud.chores.complete_chore(week_id=week_id, chore_type_id=chore_type_id)
