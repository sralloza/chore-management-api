from fastapi import Request
from fastapi.responses import JSONResponse
import sys


async def catch_exceptions_middleware(request: Request, call_next):
    try:
        return await call_next(request)
    except Exception as exc:
        # TODO: log exception
        print(exc, file=sys.stderr)
        return JSONResponse({"message": "Internal server error"}, status_code=500)
