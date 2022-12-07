from .. import crud
from .week_ids import get_current_week_id


async def clean_old_deactivated_weeks():
    print("Cleaning old deactivated weeks")
    deactivated_weeks = await crud.deactivated_weeks.get_multi()
    current_week_id = get_current_week_id().week_id
    for deactivated_week in deactivated_weeks:
        if deactivated_week.week_id < current_week_id:
            await crud.deactivated_weeks.delete(id=deactivated_week.id)
