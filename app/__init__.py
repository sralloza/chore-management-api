from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.responses import ORJSONResponse
from prometheus_fastapi_instrumentator import Instrumentator

from .api import router as router_v1
from .db.session import database
from .middlewares.correlator import inject_correlator
from .middlewares.errors import internal_exception_handler, validation_exception_handler

app = FastAPI(default_response_class=ORJSONResponse)
app.exception_handler(500)(internal_exception_handler)
app.exception_handler(RequestValidationError)(validation_exception_handler)
app.middleware("http")(inject_correlator)

app.include_router(router_v1, prefix="/api/v1")


@app.on_event("startup")
async def startup():
    Instrumentator(
        excluded_handlers=["/metrics", "/health"],
        should_group_status_codes=False,
        should_group_untemplated=False,
    ).instrument(app).expose(app)
    await database.connect()


@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()


@app.get("/health")
def health():
    return {"status": "OK"}
