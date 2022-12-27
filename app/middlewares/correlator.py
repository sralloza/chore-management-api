from uuid import uuid4

from fastapi import Request
from starlette.datastructures import MutableHeaders

X_CORRELATOR_HEADER_NAME = "X-Correlator"


async def inject_correlator_request(request: Request, call_next):
    xcorrelator = request.headers.get(X_CORRELATOR_HEADER_NAME) or str(uuid4())

    headers = MutableHeaders(request._headers)
    headers[X_CORRELATOR_HEADER_NAME] = xcorrelator
    request._headers = headers
    request.scope.update(headers=request.headers.raw)
    return await call_next(request)


async def inject_correlator_response(request: Request, call_next):
    xcorrelator = request.headers.get(X_CORRELATOR_HEADER_NAME)
    response = await call_next(request)
    response.headers[X_CORRELATOR_HEADER_NAME] = xcorrelator
    return response
