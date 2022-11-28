import sqlalchemy as sa

from .session import *
from .tables import *

engine = sa.create_engine(url, pool_pre_ping=True, connect_args={})
