from typing import Any, Generic, List, Optional, Type, TypeVar

from fastapi import HTTPException
from pydantic import BaseModel
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlmodel import SQLModel

ModelType = TypeVar("ModelType", bound=SQLModel)
IDType = TypeVar("IDType", bound=Any)
CreateSchemaType = TypeVar("CreateSchemaType", bound=BaseModel)
UpdateSchemaType = TypeVar("UpdateSchemaType", bound=BaseModel)


class CRUDBase(Generic[ModelType, CreateSchemaType, UpdateSchemaType, IDType]):
    def __init__(self, model: Type[ModelType]):
        """
        CRUD object with default methods to Create, Read, Update, Delete (CRUD).
        **Parameters**
        * `model`: A SQLAlchemy model class
        * `schema`: A Pydantic model (schema) class
        """
        self.model = model

    def get_model_id(self) -> IDType:
        return self.model.id

    async def get(self, db: AsyncSession, id: IDType) -> Optional[ModelType]:
        result = await db.execute(select(self.model).where(self.get_model_id() == id))
        return result.scalars().first()

    async def get_or_404(self, db: AsyncSession, id: IDType) -> ModelType:
        obj = await self.get(db, id=id)
        if obj is not None:
            return obj
        detail = f"{self.model.__name__} with id={id} does not exist"
        raise HTTPException(404, detail)

    async def get_multi(
        self, db: AsyncSession, *, skip: int = 0, limit: int = 100
    ) -> List[ModelType]:
        result = await db.execute(select(self.model).offset(skip).limit(limit))
        return result.scalars().all()

    async def create(self, db: AsyncSession, *, obj_in: CreateSchemaType) -> ModelType:
        obj_in_data = obj_in.dict()
        if "id" in obj_in_data and await self.get(db, id=obj_in_data["id"]):
            detail = f"{self.model.__name__} with id={obj_in_data['id']} already exists"
            raise HTTPException(409, detail)

        db_obj = self.model(**obj_in_data)
        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return db_obj

    @staticmethod
    async def update(
        db: AsyncSession,
        *,
        db_obj: ModelType,
        obj_in: UpdateSchemaType,
    ) -> ModelType:

        obj_data = obj_in.dict(exclude_unset=True)
        for field in obj_data:
            setattr(db_obj, field, obj_data[field])

        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return db_obj

    async def remove(self, db: AsyncSession, *, id: IDType) -> None:
        obj = self.get_or_404(db, id=id)
        await db.delete(obj)
        await db.commit()
