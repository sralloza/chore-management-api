from fastapi import FastAPI

from .middlewares.errors import catch_exceptions_middleware
from .routes import router as router_v1

app = FastAPI()
app.middleware("http")(catch_exceptions_middleware)

app.include_router(router_v1, prefix="/v1")
