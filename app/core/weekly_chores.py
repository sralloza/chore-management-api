from itertools import groupby

from fastapi import HTTPException

from .. import crud
from ..core.users import calculate_hash
from ..core.utils import expand_array, rotate_array
from ..models.chore import ChoreCreate
from ..models.chore_type import ChoreType
from ..models.rotations import Rotation
from ..models.settings import RotationSign
from ..models.weekly_chores import WeeklyChore, WeeklyChores


async def create_next_weekly_chores(week_id: str):
    deactivated_weeks = await crud.deactivated_weeks.get(id=week_id)
    if deactivated_weeks:
        raise HTTPException(
            400,
            f"Week {week_id} is deactivated",
        )

    users = await crud.user.get_multi()
    chore_types = await crud.chore_types.get_multi()
    chores = await crud.chores.get_multi(week_id=week_id)

    if not users:
        raise HTTPException(400, "Can't create weekly chores, no users registered")
    if not chore_types:
        raise HTTPException(
            400, "Can't create weekly chores, no chore types registered"
        )
    if chores:
        raise HTTPException(
            409,
            f"Weekly chores for week {week_id} already exist",
        )

    rotation = await crud.rotation.get_last_rotation()
    if rotation is None:
        return await create_first_weekly_chores(chore_types, week_id)

    users_hash = calculate_hash([user.id for user in users])
    if rotation.user_ids_hash != users_hash:
        raise HTTPException(400, "Users have changed since last weekly chores creation")

    return await create_weekly_chores(chore_types, week_id, rotation.rotation)


async def create_weekly_chores(
    chore_types: list[ChoreType], week_id: str, last_rotation: int
):
    settings = await crud.settings.get_or_404()
    user_ids = crud.settings.map_to_io(settings).assignment_order
    max_len = len(user_ids) * len(chore_types)
    expanded_user_ids = expand_array(user_ids, max_len)

    new_rotation = abs(last_rotation) + 1
    if new_rotation >= max_len:
        new_rotation -= max_len

    if settings.rotation_sign == RotationSign.positive:
        new_rotation = -new_rotation

    expanded_user_ids = rotate_array(expanded_user_ids, new_rotation)

    chores: list[ChoreCreate] = []
    for i in range(len(chore_types)):
        chore = ChoreCreate(
            user_id=expanded_user_ids[i],
            chore_type=chore_types[i].id,
            week_id=week_id,
        )
        chores.append(chore)

    for chore in chores:
        await crud.chores.create(obj_in=chore)

    user_ids_hash = calculate_hash(user_ids)
    await crud.rotation.create(
        obj_in=Rotation(
            rotation=new_rotation, week_id=week_id, user_ids_hash=user_ids_hash
        )
    )


async def create_first_weekly_chores(chore_types: list[ChoreType], week_id: str):
    settings = await crud.settings.get_or_404()
    user_ids = crud.settings.map_to_io(settings).assignment_order
    max_len = len(user_ids) * len(chore_types)

    expanded_user_ids = expand_array(user_ids, max_len)

    chores: list[ChoreCreate] = []
    for i in range(len(chore_types)):
        chore = ChoreCreate(
            user_id=expanded_user_ids[i],
            chore_type=chore_types[i].id,
            week_id=week_id,
        )
        chores.append(chore)

    for chore in chores:
        await crud.chores.create(obj_in=chore)

    user_ids_hash = calculate_hash(user_ids)
    await crud.rotation.create(
        obj_in=Rotation(rotation=0, week_id=week_id, user_ids_hash=user_ids_hash)
    )


async def get_all_weekly_chores(missing_only=False) -> list[WeeklyChores]:
    chores = await crud.chores.get_multi()
    users = await crud.user.get_multi()

    def get_user_name(user_id: str):
        return next(user.username for user in users if user.id == user_id)

    result: list[WeeklyChores] = []
    for week_id, group in groupby(chores, lambda chore: chore.week_id):
        weekly_chores: list[WeeklyChore] = []
        for chore_type, chore_list in groupby(group, lambda x: x.chore_type):
            chore_list = list(chore_list)
            weekly_chore = WeeklyChore(
                assigned_ids=[chore.user_id for chore in chore_list],
                assigned_usernames=[
                    get_user_name(chore.user_id) for chore in chore_list
                ],
                done=all([chore.done for chore in chore_list]),
                type=chore_type,
                week_id=week_id,
            )
            weekly_chores.append(weekly_chore)
        if missing_only is False:
            result.append(WeeklyChores(chores=weekly_chores, week_id=week_id))
        else:
            if all([chore.done for chore in weekly_chores]) is False:
                result.append(WeeklyChores(chores=weekly_chores, week_id=week_id))
    return result


async def get_weekly_chores_by_week_id(week_id: str) -> WeeklyChores:
    chores = await crud.chores.get_multi(week_id=week_id)
    users = await crud.user.get_multi()

    if not chores:
        raise HTTPException(404, f"No weekly chores found for week {week_id}")

    def get_user_name(user_id: str):
        return next(user.username for user in users if user.id == user_id)

    weekly_chores: list[WeeklyChore] = []
    for chore_type, chore_list in groupby(chores, lambda x: x.chore_type):
        chore_list = list(chore_list)
        weekly_chore = WeeklyChore(
            assigned_ids=[chore.user_id for chore in chore_list],
            assigned_usernames=[get_user_name(chore.user_id) for chore in chore_list],
            done=all([chore.done for chore in chore_list]),
            type=chore_type,
            week_id=week_id,
        )
        weekly_chores.append(weekly_chore)
    return WeeklyChores(chores=weekly_chores, week_id=week_id)
