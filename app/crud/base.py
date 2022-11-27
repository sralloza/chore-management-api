from typing import Any, Generic, List, Optional, Type, TypeVar

from fastapi import HTTPException
from pydantic import BaseModel
from sqlmodel import SQLModel
from sqlmodel import Session, SQLModel, select

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

    def throw_404_exception(self, id: IDType):
        detail = f"{self.model.__name__} with id={id} does not exist"
        raise HTTPException(404, detail)

    def get(self, db: Session, id: IDType) -> Optional[ModelType]:
        return (
            db.execute(select(self.model).where(self.get_model_id() == id))
            .scalars()
            .first()
        )

    def get_or_404(self, db: Session, id: IDType) -> ModelType:
        obj = self.get(db, id=id)
        if obj is not None:
            return obj
        self.throw_404_exception(id)

    def get_multi(
        self, db: Session, *, skip: int = 0, limit: int = 100
    ) -> List[ModelType]:
        return db.execute(select(self.model).offset(skip).limit(limit)).scalars().all()

    def create(self, db: Session, *, obj_in: CreateSchemaType) -> ModelType:
        obj_in_data = obj_in.dict()
        if "id" in obj_in_data and self.get(db, id=obj_in_data["id"]):
            detail = f"{self.model.__name__} with id={obj_in_data['id']} already exists"
            raise HTTPException(409, detail)

        db_obj = self.model(**obj_in_data)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    @staticmethod
    def update(
        db: Session,
        *,
        db_obj: ModelType,
        obj_in: UpdateSchemaType,
    ) -> ModelType:

        obj_data = obj_in.dict(exclude_unset=True)
        for field in obj_data:
            setattr(db_obj, field, obj_data[field])

        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def remove(self, db: Session, *, id: IDType) -> None:
        obj = self.get_or_404(db, id=id)
        db.delete(obj)
        db.commit()
