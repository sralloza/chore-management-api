from typing import Any, Generic, List, Optional, Type, TypeVar

import i18n
from fastapi import HTTPException
from pydantic import BaseModel
from sqlalchemy import Table

from ..db.session import database

ModelType = TypeVar("ModelType", bound=BaseModel)
IDType = TypeVar("IDType", bound=Any)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)

SELECT_QUERY = "SELECT * FROM {table_name} WHERE {id} = :id"


class CRUDBase(Generic[ModelType, CreateSchemaType, UpdateSchemaType, IDType]):
    template_409 = "{model_name} with {primary_key}={id} already exists"

    def __init__(self, model: Type[ModelType], table: Table, primary_key="id"):
        self.model = model
        self.table = table

        self.primary_key = primary_key
        self.select_query = SELECT_QUERY.format(
            table_name=self.table.name, id=primary_key
        )

    def throw_conflict_exception(self, lang: str, id: IDType):
        model = i18n.t(f"model.{self.model.__name__}", locale=lang)
        detail = i18n.t(
            "crud.conflict",
            locale=lang,
            model=model,
            primary_key=self.primary_key,
            id=id,
        )
        raise HTTPException(409, detail)

    def throw_not_found_exception(self, lang: str, id: IDType):
        model = i18n.t(f"models.{self.model.__name__}", locale=lang)
        detail = i18n.t(
            "crud.not_found",
            locale=lang,
            id=id,
            model_name=model,
            primary_key=self.primary_key,
        )
        raise HTTPException(404, detail)

    async def get(self, id: IDType) -> Optional[ModelType]:
        data = await database.fetch_one(query=self.select_query, values={"id": id})
        return self.model(**data) if data else None

    async def get_or_404(self, lang: str, id: IDType) -> ModelType:
        obj = await self.get(id=id)
        if obj is not None:
            return obj
        self.throw_not_found_exception(lang, id)

    async def get_multi(
        self, *, page: int = 1, per_page: int = 30, query_mod=None, **kwargs
    ) -> List[ModelType]:
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
                self.throw_conflict_exception(lang, obj_in_data[self.primary_key])

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
