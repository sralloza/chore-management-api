from fastapi import Header, HTTPException

from ..core.config import settings


async def admin_required(x_token: str = Header(None)):
    if x_token is None:
        raise HTTPException(status_code=401, detail="Missing API key")
    if x_token != settings.admin_api_key:
        raise HTTPException(status_code=403, detail="Admin access required")
