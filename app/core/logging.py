import logging
import logging.config
from datetime import datetime
from traceback import format_exception

from fastapi import Request, Response
from orjson import dumps
from starlette.datastructures import Address

from .version import version

logger = logging.getLogger(__name__)


def format_client(client: Address):
    if not client.port:
        return client.host
    return f"{client.host}:{client.port}"


def log_request(request: Request):
    client = format_client(request.client) if request.client else None
    data = {
        "datetime": datetime.now(),
        "client": client,
        "method": request.method,
        "url": str(request.url),
        "headers": dict(request.headers),
        "version": version,
    }
    logger.info(dumps({"request": data}).decode("utf-8"))


def log_response(response: Response, timing=None):
    data = {
        "datetime": datetime.now(),
        "status_code": response.status_code,
        "headers": dict(response.headers),
        "version": version,
    }
    if timing:
        data["duration_ms"] = round(timing * 1000)
    logger.info(dumps({"response": data}).decode("utf-8"))
    return response


def log_exception(request: Request, exc: Exception):
    data = {
        "datetime": datetime.now(),
        "message": str(exc),
        "stack_trace": "".join(format_exception(exc)),
        "x-correlator": request.headers.get("x-correlator", "None"),
    }
    logger.error(dumps({"error": data}).decode("utf-8"))


def setup_logging():
    disabled_loggers = (
        "uvicorn",
        "uvicorn.access",
        "uvicorn.error",
    )
    logging_config = {
        "version": 1,
        "loggers": {
            "": {
                "level": "INFO",
                "propagate": False,
                "handlers": ["normal_handler"],
            },
            "app.core.logging": {
                "level": "DEBUG",
                "propagate": False,
                "handlers": ["access_handler"],
            },
            "app": {
                "level": "DEBUG",
                "propagate": True,
            },
        },
        "handlers": {
            "normal_handler": {
                "class": "logging.StreamHandler",
                "stream": "ext://sys.stdout",
                "level": "DEBUG",
                "filters": [],
                "formatter": "default_formatter",
            },
            "access_handler": {
                "class": "logging.StreamHandler",
                "stream": "ext://sys.stdout",
                "level": "DEBUG",
                "filters": [],
                "formatter": "access_formatter",
            },
        },
        "formatters": {
            "default_formatter": {
                "format": "[%(asctime)s] [%(levelname)s] {%(name)s}: %(message)s",
            },
            "access_formatter": {
                "format": "%(message)s",
            },
        },
    }
    print("Setting up logging")
    for logger in disabled_loggers:
        logging_config["loggers"][logger] = {"level": "CRITICAL", "propagate": False}

    logging.config.dictConfig(logging_config)

    loggers = [logging.getLogger(name) for name in logging.root.manager.loggerDict]
    print(f"Loggers: {loggers}")
