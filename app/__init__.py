from logging import getLogger
from pathlib import Path

from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError
from fastapi.responses import ORJSONResponse
from prometheus_fastapi_instrumentator import Instrumentator

from . import crud
from .api import router as router_v1
from .core.config import settings
from .core.deactivated_weeks import clean_old_deactivated_weeks
from .core.i18n import DEFAULT_LANG, load_translations
from .core.logging import setup_logging
from .core.metadata import TAGS_METADATA
from .core.scheduler import scheduler
from .core.version import version
from .db.session import database
from .middlewares.correlator import (
    inject_correlator_request,
    inject_correlator_response,
)
from .middlewares.errors import internal_exception_handler, validation_exception_handler
from .middlewares.logging import logging_middleware

logger = getLogger(__name__)

app = FastAPI(
    title="Chore Management",
    description=Path(__file__).parent.with_name("API.md").read_text(),
    default_response_class=ORJSONResponse,
    redoc_url="/docs" if not settings.is_production else None,
    docs_url=None,
    openapi_tags=TAGS_METADATA,
)

app.middleware("http")(inject_correlator_response)
app.middleware("http")(logging_middleware)
app.exception_handler(RequestValidationError)(validation_exception_handler)
app.exception_handler(500)(internal_exception_handler)
app.middleware("http")(inject_correlator_request)

app.include_router(router_v1, prefix="/api/v1")


async def setup():
    setup_logging()
    load_translations()
    if settings.is_production:
        logger.info("Running in PRO environment")

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

    if not await crud.settings.get():
        await crud.settings.create_default(lang=DEFAULT_LANG)


@app.on_event("startup")
async def startup():
    try:
        await setup()
        logger.info("Application started")
    except:
        logger.exception("Failed to start application")
        raise


@app.on_event("shutdown")
async def shutdown():
    logger.info("Application shutting down")
    await database.disconnect()
    logger.info("Application shut down")


@app.get("/health", include_in_schema=False)
def health():
    return {"status": "OK", "version": version}
