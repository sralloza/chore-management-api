from uuid import uuid4
from fastapi import Request


async def inject_correlator(request: Request, call_next):
    xcorrelator = request.headers.get("X-Correlator") or str(uuid4())
    response = await call_next(request)
    response.headers["X-Correlator"] = xcorrelator
    return response
