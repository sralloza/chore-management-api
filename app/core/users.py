from copy import deepcopy
from hashlib import sha256

import i18n
from fastapi import HTTPException

from .. import crud
from ..core.config import settings


async def expand_user_id(user_id: str, x_token: str, lang: str) -> str:
    if user_id != "me":
        return user_id

    if x_token == settings.admin_api_key:
        detail = i18n.t("auth.bad_request.keyword_me_admin", locale=lang)
        raise HTTPException(status_code=400, detail=detail)

    users = await crud.user.get_multi(api_key=x_token)
    if users:
        return users[0].id

    raise ValueError("Can't expand user_id (configuration error)")


def calculate_hash(user_ids: list[str]) -> str:
    user_ids = deepcopy(user_ids)
    user_ids.sort()
    return sha256("".join(user_ids).encode()).hexdigest()
