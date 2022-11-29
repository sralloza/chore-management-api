from fastapi import FastAPI, HTTPException
from fastapi.exceptions import RequestValidationError
from prometheus_fastapi_instrumentator import Instrumentator

from .api import router as router_v1
from .db.session import database
from .middlewares.correlator import inject_correlator
from .middlewares.errors import (
    http_exception_handler,
    internal_exception_handler,
    validation_exception_handler,
)

app = FastAPI()
app.exception_handler(500)(internal_exception_handler)
app.exception_handler(HTTPException)(http_exception_handler)
app.exception_handler(RequestValidationError)(validation_exception_handler)
app.middleware("http")(inject_correlator)

app.include_router(router_v1, prefix="/api/v1")


@app.on_event("startup")
async def startup():
    Instrumentator().instrument(app).expose(app)
    await database.connect()


@app.on_event("shutdown")
async def shutdown():
    await database.disconnect()


@app.get("/health")
def health():
    return {"status": "ok"}
