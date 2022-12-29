import i18n
from fastapi import HTTPException, Security
from fastapi.security import APIKeyHeader

from .. import crud
from ..core.config import settings
from ..core.params import LANG_HEADER, USER_ID_PATH

APIKeySecurity = Security(APIKeyHeader(name="X-Token", auto_error=False))


def raise_401_exception(lang: str):
    raise HTTPException(status_code=401, detail=i18n.t("auth.401", locale=lang))


def raise_admin_access_required(lang: str):
    detail = i18n.t("auth.admin-required", locale=lang)
    raise HTTPException(status_code=403, detail=detail)


def raise_user_access_required(lang: str):
    detail = i18n.t("auth.user-required", locale=lang)
    raise HTTPException(status_code=403, detail=detail)


def admin_required(x_token: str = APIKeySecurity, lang: str = LANG_HEADER):
    if x_token is None:
        raise_401_exception(lang)
    if x_token != settings.admin_api_key:
        raise_admin_access_required(lang)


async def user_required(*, x_token: str = APIKeySecurity, lang: str = LANG_HEADER):
    if x_token is None:
        raise_401_exception(lang)
    if x_token == settings.admin_api_key:
        return

    users = await crud.user.get_multi()
    for user in users:
        if user.api_key == x_token:
            return

    raise_user_access_required(lang)


async def user_required_me_path(
    *,
    x_token: str = APIKeySecurity,
    user_id: str = USER_ID_PATH,
    lang: str = LANG_HEADER
):
    if x_token is None:
        raise_401_exception(lang)
    if x_token == settings.admin_api_key:
        if user_id == "me":
            raise HTTPException(
                status_code=400,
                detail=i18n.t("auth.keyword-me-admin", locale=lang),
            )
        return

    users = await crud.user.get_multi()
    for user in users:
        if user.api_key == x_token:
            if user_id != "me" and user_id != user.id:
                raise HTTPException(
                    status_code=403, detail=i18n.t("auth.403-user-data", locale=lang)
                )
            return

    raise_user_access_required(lang)


async def get_user_id_from_api_key(
    *, x_token: str = APIKeySecurity, lang: str = LANG_HEADER
) -> str | None:
    """Returns the user ID if the API key is valid, or None if it's the admin"""
    if x_token is None:
        raise_401_exception(lang)
    if x_token == settings.admin_api_key:
        return

    users = await crud.user.get_multi()
    for user in users:
        if user.api_key == x_token:
            return user.id

    raise_user_access_required(lang)
