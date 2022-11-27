from uuid import uuid4

from sqlalchemy.ext.asyncio import AsyncSession

# from ..models import System, SystemCreate
from .base import CRUDBase

# SystemUpdate = SystemCreate


# class CRUDSystem(CRUDBase[System, System, SystemUpdate, str]):
    # pass

# system = CRUDSystem(System)
system = None
