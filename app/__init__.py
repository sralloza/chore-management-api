from logging import getLogger
from pathlib import Path

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.responses import ORJSONResponse
from prometheus_fastapi_instrumentator import Instrumentator
from toml import loads

from .api import router as router_v1
from .core.config import settings
from .core.deactivated_weeks import clean_old_deactivated_weeks
from .core.logging import setup_logging
from .core.scheduler import scheduler
from .db.session import database
from .middlewares.correlator import (
    inject_correlator_request,
    inject_correlator_response,
)
from .middlewares.errors import internal_exception_handler, validation_exception_handler
from .middlewares.logging import logging_middleware

logger = getLogger(__name__)
version = loads(Path("pyproject.toml").read_text())["tool"]["poetry"]["version"]

app = FastAPI(
    title="Chore Management",
    description=Path(__file__).parent.with_name("API.md").read_text(),
    default_response_class=ORJSONResponse,
)

app.middleware("http")(inject_correlator_response)
app.middleware("http")(logging_middleware)
app.exception_handler(RequestValidationError)(validation_exception_handler)
app.exception_handler(500)(internal_exception_handler)
app.middleware("http")(inject_correlator_request)

app.include_router(router_v1, prefix="/api/v1")


@app.on_event("startup")
async def startup():
    setup_logging()
    Instrumentator(
        excluded_handlers=["/metrics", "/health"],
        should_group_status_codes=False,
        should_group_untemplated=False,
    ).instrument(app).expose(app, include_in_schema=False)
    await database.connect()
    if settings.enable_db_cleanup:
        scheduler.add_job(
            clean_old_deactivated_weeks,
            "interval",
            days=1,
            id="clean-old-deactivated-weeks",
        )
        scheduler.start()
        scheduler.print_jobs()
    logger.info("Application started")


@app.on_event("shutdown")
async def shutdown():
    logger.info("Application shutting down")
    await database.disconnect()
    logger.info("Application shut down")


@app.get("/health", include_in_schema=False)
def health():
    return {"status": "OK", "version": version}
