from fastapi import APIRouter, Depends, Query

from .. import crud
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
        401: {"model": Message, "description": "Missing API key"},
        403: {"model": Message, "description": "User access required"},
    },
)
async def list_chores(
    chore_type_id: int = Query(None, description="Filter by chore type ID"),
    user_id: int = Query(None, description="Filter by user ID"),
    week_id: str = Query(
        None, description="Filter by week ID", regex=r"^\d{4}\.\d{2}$"
    ),
    done: bool = Query(None, description="Filter by status"),
):
    # TODO: Validate user-id (the me keyword)
    kwargs = {
        "chore_type_id": chore_type_id,
        "user_id": user_id,
        "week_id": week_id,
        "done": done,
    }
    return await crud.chores.get_multi(**kwargs)
