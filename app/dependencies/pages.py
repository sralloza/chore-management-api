from collections import namedtuple

from fastapi import Query

PaginationParams = namedtuple("PaginationParams", "page, per_page")


async def pagination_params(
    page: int = Query(1, description="Page number, starting with 1"),
    per_page: int = Query(10, description="Page size"),
):
    return PaginationParams(page, per_page)
