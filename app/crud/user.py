from uuid import uuid4

from sqlmodel import Session
from sqlalchemy.future import select

from ..models import User, UserCreate
from .base import CRUDBase
from .. import crud

UserUpdate = UserCreate


class CRUDUser(CRUDBase[User, User, UserUpdate, str]):
    def create(self, db: Session, *, obj_in: UserCreate) -> User:
        user = User(**obj_in.dict(), api_key=str(uuid4()))
        result = super().create(db, obj_in=user)
        crud.settings.reset_assignment_order(db)
        return result

    def get_or_404_me_safe(
        self, db: Session, *, api_key: str, id: str
    ) -> User:
        if id == "me":
            result = db.execute(
                select(self.model).where(self.model.api_key == api_key)
            )
            db_user = result.scalars().first()
            if not db_user:
                self.throw_404_exception(id)
            return db_user
        else:
            return self.get_or_404(db, id=id)

    def get_user_ids(self, db: Session) -> list[str]:
        result = db.execute(select(self.model.id).order_by(self.model.created_at))
        return result.scalars().all()


user = CRUDUser(User)
