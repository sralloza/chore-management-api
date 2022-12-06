from fastapi import Request, status
from fastapi.encoders import jsonable_encoder
from fastapi.exceptions import RequestValidationError
from fastapi.responses import ORJSONResponse


def internal_exception_handler(request: Request, exc: Exception):
    return ORJSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content=jsonable_encoder({"detail": "Internal server error"}),
    )


async def validation_exception_handler(request: Request, exc: RequestValidationError):
    for error in exc.errors():
        if error["type"] == "value_error.jsondecode":
            return ORJSONResponse(
                status_code=status.HTTP_400_BAD_REQUEST,
                content=jsonable_encoder(
                    {"detail": "Request body is not a valid JSON"}
                ),
            )
    return ORJSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content=jsonable_encoder({"errors": exc.errors()}),
    )
