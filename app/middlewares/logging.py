import logging

from fastapi import Request

from ..core.logging import log_request, log_response

logger = logging.getLogger(__name__)


async def logging_middleware(request: Request, call_next):
    log_request(request)
    response = await call_next(request)
    log_response(response)
    return response
