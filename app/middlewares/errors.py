import logging

from fastapi import Request, status
from fastapi.encoders import jsonable_encoder
from fastapi.exceptions import RequestValidationError
from fastapi.responses import ORJSONResponse

from ..core.logging import log_exception
from .correlator import X_CORRELATOR_HEADER_NAME

logger = logging.getLogger(__name__)


def internal_exception_handler(request: Request, exc: Exception):
    log_exception(request, exc)
    xcorrelator = request.headers.get(X_CORRELATOR_HEADER_NAME)
    headers = {X_CORRELATOR_HEADER_NAME: xcorrelator} if xcorrelator else None
    return ORJSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content=jsonable_encoder({"detail": "Internal server error"}),
        headers=headers,
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError):
    xcorrelator = request.headers.get(X_CORRELATOR_HEADER_NAME)
    headers = {X_CORRELATOR_HEADER_NAME: xcorrelator} if xcorrelator else None

    for error in exc.errors():
        if error["type"] == "value_error.jsondecode":
            return ORJSONResponse(
                status_code=status.HTTP_400_BAD_REQUEST,
                content=jsonable_encoder(
                    {"detail": "Request body is not a valid JSON"}
                ),
                headers=headers,
            )
    return ORJSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content=jsonable_encoder({"errors": exc.errors()}),
        headers=headers,
    )
