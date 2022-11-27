from fastapi import Depends, Header, HTTPException
from sqlmodel import Session

from .. import crud
from ..core.config import settings
from ..dependencies.db import get_db


def admin_required(x_token: str = Header(None)):
    if x_token is None:
        raise HTTPException(status_code=401, detail="Missing API key")
    if x_token != settings.admin_api_key:
        raise HTTPException(status_code=403, detail="Admin access required")


def user_required_me_path(
    *, x_token: str = Header(None), user_id: str, db: Session = Depends(get_db)
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

    users = crud.user.get_multi(db)
    for user in users:
        print(user)
        if user.api_key == x_token:
            if user_id != "me" and user_id != user.id:
                raise HTTPException(
                    status_code=403,
                    detail="You don't have permission to access this user's data",
                )
            return

    raise HTTPException(status_code=403, detail="User access required")
