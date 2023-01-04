import re
from typing import Any, Callable, Generic, Type, TypeVar

import i18n
import sqlalchemy as sa
from fastapi import HTTPException
from pydantic import BaseModel
from sqlalchemy.sql.selectable import Select

from ..db.session import database

ModelType = TypeVar("ModelType", bound=BaseModel)
IDType = TypeVar("IDType", bound=Any)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)

SELECT_QUERY = "SELECT * FROM {table_name} WHERE {id} = :id"


class CRUDBase(Generic[ModelType, CreateSchemaType, UpdateSchemaType, IDType]):
    spanish_model_fem = False

    def __init__(self, model: Type[ModelType], table: sa.Table, primary_key="id"):
        self.model = model
        self.table = table

        self.primary_key = primary_key
        self.select_query = SELECT_QUERY.format(
            table_name=self.table.name, id=primary_key
        )

    def get_model_name(self, lang: str, lower=False):
        result = i18n.t(f"models.{self.model.__name__}", locale=lang)
        if lower:
            return re.sub("([A-Z][a-z]+)", r" \1", result).strip().lower()
        return result

    def get_not_found_detail(self, lang: str, id: IDType):
        key = "crud.not_found"
        if self.spanish_model_fem and lang == "es":
            key += ".fem"

        return i18n.t(
            key,
            locale=lang,
            id=id,
            model_name=self.get_model_name(lang=lang),
            primary_key=self.primary_key,
        )

    def throw_conflict_exception(self, *, lang: str, id: IDType):
        detail = i18n.t(
            "crud.conflict",
            locale=lang,
            model_name=self.get_model_name(lang=lang),
            primary_key=self.primary_key,
            id=id,
        )
        raise HTTPException(409, detail)

    def throw_not_found_exception(self, lang: str, id: IDType):
        raise HTTPException(404, self.get_not_found_detail(lang, id))

    async def get(self, id: IDType) -> ModelType | None:
        data = await database.fetch_one(query=self.select_query, values={"id": id})
        return self.model(**data) if data else None

    async def get_or_404(self, lang: str, id: IDType) -> ModelType:
        obj = await self.get(id=id)
        if obj is not None:
            return obj
        self.throw_not_found_exception(lang=lang, id=id)

    async def get_multi(
        self,
        *,
        page: int = 1,
        per_page: int = 30,
        query_mod: Callable[[Select], Select] | None = None,
        **kwargs,
    ) -> list[ModelType]:
        query = self.table.select().offset((page - 1) * per_page).limit(per_page)
        if query_mod is not None:
            query = query_mod(query)

        for key, value in kwargs.items():
            try:
                field = getattr(self.table.c, key)
            except AttributeError:
                raise ValueError(f"Invalid field {key} for {self.model.__name__}")
            if value is not None:
                query = query.where(field == value)

        data = await database.fetch_all(query)
        return [self.model(**x) for x in data]

    async def create(
        self, *, lang: str, obj_in: CreateSchemaType, check_409: bool = True
    ) -> ModelType:
        obj_in_data = obj_in.dict()
        if self.primary_key in obj_in_data and check_409:
            if await self.get(id=obj_in_data[self.primary_key]):
                self.throw_conflict_exception(
                    lang=lang, id=obj_in_data[self.primary_key]
                )

        db_id = await database.execute(self.table.insert(), obj_in_data)
        real_id = (
            obj_in_data[self.primary_key] if self.primary_key in obj_in_data else db_id
        )
        return await self.get_or_404(lang=lang, id=real_id)

    async def update(
        self,
        *,
        lang: str,
        id: IDType,
        obj_in: UpdateSchemaType,
    ) -> ModelType:
        await self.get_or_404(lang=lang, id=id)
        values = obj_in.dict(exclude_unset=True)
        if values:
            query = self.table.update().where(self.table.c.id == id).values(values)
            await database.execute(query)

        return await self.get_or_404(lang=lang, id=id)

    async def delete(self, *, lang: str, id: IDType) -> None:
        await self.get_or_404(lang=lang, id=id)
        await database.execute(self.table.delete().where(self.table.c.id == id))

    async def count(self)->int:
        query = sa.select([sa.func.count(self.table.c.id)])
        result = await database.fetch_one(query)
        if result is None:
            return 0
        return int(result[0])
