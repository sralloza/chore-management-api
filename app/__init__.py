from fastapi import Depends, FastAPI
from sqlalchemy.orm import Session

from .core.config import settings
from .middlewares.db import get_db
from .models.user import User
app = FastAPI()


@app.get("/")
async def root():
    return settings

@app.get("/test")
async def test(db: Session = Depends(get_db)):
    return db.query(User).first()
