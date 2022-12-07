from fastapi import HTTPException, Security
from fastapi.security import APIKeyHeader

from .. import crud
from ..core.config import settings
from ..core.constants import USER_ID_PATH

APIKeySecurity = Security(APIKeyHeader(name="X-Token", auto_error=False))


def admin_required(x_token: str = APIKeySecurity):
    if x_token is None:
        raise HTTPException(status_code=401, detail="Missing API key")
    if x_token != settings.admin_api_key:
        raise HTTPException(status_code=403, detail="Admin access required")


async def user_required(*, x_token: str = APIKeySecurity):
    if x_token is None:
        raise HTTPException(status_code=401, detail="Missing API key")
    if x_token == settings.admin_api_key:
        return

    users = await crud.user.get_multi()
    for user in users:
        if user.api_key == x_token:
            return

    raise HTTPException(status_code=403, detail="User access required")


async def user_required_me_path(
    *, x_token: str = APIKeySecurity, user_id: str = USER_ID_PATH
):
    if x_token is None:
        raise HTTPException(status_code=401, detail="Missing API key")
    if x_token == settings.admin_api_key:
        if user_id == "me":
            raise HTTPException(
                status_code=400,
                detail="Can't use the special keyword me with the admin API key",
            )
        return

    users = await crud.user.get_multi()
    for user in users:
        if user.api_key == x_token:
            if user_id != "me" and user_id != user.id:
                raise HTTPException(
                    status_code=403,
                    detail="You don't have permission to access this user's data",
                )
            return

    raise HTTPException(status_code=403, detail="User access required")
