from ..core.config import settings
from fastapi import HTTPException
from .. import crud


async def expand_user_id(user_id: str, x_token: str) -> str:
    if user_id != "me":
        return user_id

    if x_token == settings.admin_api_key:
        raise HTTPException(
            status_code=400,
            detail="Can't use the special keyword me with the admin API key",
        )

    users = await crud.user.get_multi()
    for user in users:
        if user.api_key == x_token:
            return user.id

    raise ValueError("Can't expand user_id (configuration error)")
