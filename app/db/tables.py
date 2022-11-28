import time
from datetime import datetime

import sqlalchemy as sa

from ..models import RotationSign
from .session import metadata

__all__ = ["chore_type", "chore", "settings", "ticket", "transfer", "user"]

chore_type = sa.Table(
    "chore_type",
    metadata,
    sa.Column("id", sa.String(25), primary_key=True, nullable=False),
    sa.Column("name", sa.String(50), nullable=False),
    sa.Column("description", sa.String(255), nullable=False),
)

chore = sa.Table(
    "chore",
    metadata,
    sa.Column("id", sa.Integer, primary_key=True, nullable=False),
    sa.Column("chore_type", sa.String(25), nullable=False),
    sa.Column("done", sa.Boolean, nullable=False, default=False),
    sa.Column("user_id", sa.String(40), nullable=False),
    sa.Column("week_id", sa.String(7), nullable=False),
)

settings = sa.Table(
    "settings",
    metadata,
    sa.Column("id", sa.String(36), primary_key=True, nullable=False),
    sa.Column("rotation_sign", sa.Enum(RotationSign), nullable=False),
    sa.Column("assignment_order", sa.String(2048), nullable=False),
)

ticket = sa.Table(
    "ticket",
    metadata,
    sa.Column("id", sa.Integer, primary_key=True, nullable=False),
    sa.Column("chore_type_id", sa.String(25), nullable=False),
    sa.Column("user_id", sa.String(40), nullable=False),
    sa.Column("tickets", sa.Integer, nullable=False),
)

transfer = sa.Table(
    "transfer",
    metadata,
    sa.Column("id", sa.Integer, primary_key=True, nullable=False),
    sa.Column("accepted", sa.Boolean, default=False, nullable=False),
    sa.Column("chore_type_id", sa.String(25), nullable=False),
    sa.Column("completed", sa.Boolean, default=False, nullable=False),
    sa.Column("user_id_from", sa.String(40), nullable=False),
    sa.Column("user_id_to", sa.String(40), nullable=False),
    sa.Column("created_at", sa.DateTime, default=datetime.now),
    sa.Column("closed_at", sa.DateTime, nullable=True),
    sa.Column("week_id", sa.String(7), nullable=False),
)

user = sa.Table(
    "user",
    metadata,
    sa.Column("id", sa.String(40), nullable=False, primary_key=True),
    sa.Column("username", sa.String(25), nullable=False),
    sa.Column("api_key", sa.String(36), nullable=False, unique=True),
    sa.Column(
        "created_at",
        sa.BigInteger(),
        nullable=False,
        default=lambda: time.time() * 10**6,
    ),
)
