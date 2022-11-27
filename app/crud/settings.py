from sqlmodel import Session

from .. import crud
from ..models import RotationSign, Settings, SettingsCreate, SettingsIO, SettingsUpdate
from .base import CRUDBase

REAL_ID = "9ccce886-4fe2-42fc-872e-3afc2fa14ccf"


class CRUDSettings(CRUDBase[Settings, SettingsCreate, SettingsUpdate, str]):
    def get(self, db: Session, **kwargs) -> Settings | None:
        return super().get(db, id=REAL_ID)

    def get_or_404(self, db: Session) -> Settings:
        return super().get_or_404(db, id=REAL_ID)

    def reset_assignment_order(self, db: Session):
        settings = self.get(db)
        user_ids = crud.user.get_user_ids(db)

        if not settings:
            settings = super().create(
                db,
                obj_in=SettingsCreate(
                    id=REAL_ID,
                    rotation_sign=RotationSign.positive,
                    assignment_order=",".join(user_ids),
                ),
            )

        else:
            settings.assignment_order = ",".join(user_ids)
            # db.execute(update(Settings), values={Settings.assignment_order: ",".join(user_ids)})

        db.commit()

    @staticmethod
    def map_to_io(settings: Settings) -> SettingsIO:
        return SettingsIO(
            id=settings.id,
            rotation_sign=settings.rotation_sign,
            assignment_order=settings.assignment_order.split(","),
        )


settings = CRUDSettings(Settings)
