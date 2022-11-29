import sqlalchemy as sa

from .session import url
from .tables import *  # noqa: F403

engine = sa.create_engine(url, pool_pre_ping=True, connect_args={})
