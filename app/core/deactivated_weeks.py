from .. import crud
from .i18n import DEFAULT_LANG
from .week_ids import get_current_week_id


async def clean_old_deactivated_weeks():
    print("Cleaning old deactivated weeks")
    nusers = await crud.user.count()
    deactivated_weeks = await crud.deactivated_weeks.get_multi(per_page=nusers + 1)
    current_week_id = get_current_week_id().week_id
    for deactivated_week in deactivated_weeks:
        if deactivated_week.week_id < current_week_id:
            await crud.deactivated_weeks.delete(
                lang=DEFAULT_LANG, id=deactivated_week.id
            )
