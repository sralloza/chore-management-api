from typing import Any, Generic, List, Optional, Type, TypeVar

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
    def __init__(self, model: Type[ModelType], table: Table, primary_key="id"):
        self.model = model
        self.table = table

        self.primary_key = primary_key
        self.select_query = SELECT_QUERY.format(
            table_name=self.table.name, id=primary_key
        )

    def throw_404_exception(self, id: IDType):
        detail = f"{self.model.__name__} with id={id} does not exist"
        raise HTTPException(404, detail)

    async def get(self, id: IDType) -> Optional[ModelType]:
        data = await database.fetch_one(query=self.select_query, values={"id": id})
        return self.model(**data) if data else None

    async def get_or_404(self, id: IDType) -> ModelType:
        obj = await self.get(id=id)
        if obj is not None:
            return obj
        self.throw_404_exception(id)

    async def get_multi(self, *, skip: int = 0, limit: int = 100) -> List[ModelType]:
        data = await database.fetch_all(self.table.select().offset(skip).limit(limit))
        return [self.model(**x) for x in data]

    async def create(self, *, obj_in: CreateSchemaType) -> ModelType:
        obj_in_data = obj_in.dict()
        if self.primary_key in obj_in_data and await self.get(
            id=obj_in_data[self.primary_key]
        ):
            detail = f"{self.model.__name__} with {self.primary_key}={obj_in_data[self.primary_key]} already exists"
            raise HTTPException(409, detail)

        db_id = await database.execute(self.table.insert(), obj_in_data)
        real_id = (
            obj_in_data[self.primary_key] if self.primary_key in obj_in_data else db_id
        )
        return await self.get_or_404(id=real_id)

    async def update(
        self,
        *,
        id: IDType,
        obj_in: UpdateSchemaType,
    ) -> ModelType:
        await self.get_or_404(id=id)
        values = obj_in.dict(exclude_unset=True)

        query = self.table.update().where(self.table.c.id == id).values(values)
        await database.execute(query)

        return await self.get_or_404(id=id)

    async def delete(self, *, id: IDType) -> None:
        await self.get_or_404(id=id)
        await database.execute(self.table.delete().where(self.table.c.id == id))
