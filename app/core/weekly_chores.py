from itertools import groupby
from typing import Sequence

import i18n
from fastapi import HTTPException

from .. import crud
from ..core.users import calculate_hash
from ..core.utils import expand_array, rotate_array
from ..models.chore import Chore, ChoreCreate
from ..models.chore_type import ChoreType
from ..models.rotations import Rotation
from ..models.settings import RotationSign
from ..models.weekly_chores import WeeklyChore, WeeklyChores


def throw_no_weekly_chores_found_exception(week_id: str, lang: str):
    detail = i18n.t("weekly_chores.no_chores_found", locale=lang, week_id=week_id)
    raise HTTPException(404, detail)


async def create_weekly_chores(
    week_id: str, *, dry_run: bool = False, force: bool = False, lang: str
):
    deactivated_weeks = await crud.deactivated_weeks.get(id=week_id)
    if deactivated_weeks:
        detail = i18n.t("weekly_chores.deactivated_week", locale=lang, week_id=week_id)
        raise HTTPException(400, detail)

    users = await crud.user.get_multi()
    if not users:
        detail = i18n.t("weekly_chores.no_users_found", locale=lang)
        raise HTTPException(400, detail)

    chore_types = await crud.chore_types.get_multi()
    if not chore_types:
        detail = i18n.t("weekly_chores.no_chore_types", locale=lang)
        raise HTTPException(400, detail)

    chores = await crud.chores.get_multi(week_id=week_id)
    if chores:
        detail = i18n.t("weekly_chores.already_exist", locale=lang, week_id=week_id)
        raise HTTPException(409, detail)

    rotation = await crud.rotation.get_last_rotation()
    if rotation is None:
        return await _create_weekly_chores(chore_types, week_id, lang, dry_run=dry_run)

    users_hash = calculate_hash([user.id for user in users])
    if rotation.user_ids_hash != users_hash:
        if force is False:
            detail = i18n.t("weekly_chores.users_changed", locale=lang)
            raise HTTPException(400, detail)
        return await _create_weekly_chores(chore_types, week_id, lang, dry_run=dry_run)

    chore_types_hash = calculate_hash([chore_type.id for chore_type in chore_types])
    if rotation.chore_types_hash != chore_types_hash:
        if force is False:
            detail = i18n.t("weekly_chores.chore_types_changed", locale=lang)
            raise HTTPException(400, detail)
        return await _create_weekly_chores(chore_types, week_id, lang, dry_run=dry_run)

    return await _create_weekly_chores(
        chore_types, week_id, lang, rotation.rotation, dry_run=dry_run
    )


def get_rotation_sign(settings):
    return -1 if settings.rotation_sign == RotationSign.negative else 1


async def _create_weekly_chores(
    chore_types: list[ChoreType],
    week_id: str,
    lang: str,
    last_rotation: int | None = None,
    dry_run: bool = False,
) -> list[Chore]:
    settings = await crud.settings.get(lang=lang)
    if settings is None:
        settings = await crud.settings.create_default(lang=lang)
    deactivated_weeks = await crud.deactivated_weeks.get_multi(
        week_id=week_id, assigned_to_user=True
    )
    user_ids = crud.settings.map_to_io(settings).assignment_order

    user_ids_skipping = [x.user_id for x in deactivated_weeks]
    user_ids_not_skipping = [x for x in user_ids if x not in user_ids_skipping]

    max_len = len(user_ids) * len(chore_types)
    expanded_user_ids = expand_array(user_ids, max_len)

    increment_rotation = True
    if len(deactivated_weeks) == len(chore_types) - 1:
        skipping = set([x.user_id for x in deactivated_weeks])
        user_alone = list(set(user_ids) - skipping)[0]
        expanded_user_ids = [user_alone] * len(expanded_user_ids)
        increment_rotation = False

    if last_rotation is not None:
        new_rotation = last_rotation
        if increment_rotation:
            new_rotation += get_rotation_sign(settings)

        if new_rotation >= max_len:
            new_rotation -= max_len
    else:
        if not increment_rotation:
            new_rotation = -1 * get_rotation_sign(settings)
        else:
            new_rotation = 0

    expanded_user_ids = rotate_array(expanded_user_ids, new_rotation)

    chores: list[ChoreCreate] = []
    for i in range(len(chore_types)):
        if expanded_user_ids[i] not in user_ids_skipping:
            chore = ChoreCreate(
                user_id=expanded_user_ids[i],
                chore_type_id=chore_types[i].id,
                week_id=week_id,
            )
            chores.append(chore)
        else:
            for user_id in user_ids_not_skipping:
                chore = ChoreCreate(
                    user_id=user_id,
                    chore_type_id=chore_types[i].id,
                    week_id=week_id,
                )
                chores.append(chore)

    if dry_run:
        return [Chore(**x.dict(), id=-1) for x in chores]

    real_chores: list[Chore] = []
    for chore in chores:
        new_chore = await crud.chores.create(lang=lang, obj_in=chore)
        real_chores.append(new_chore)

    user_ids_hash = calculate_hash(user_ids)
    chore_types_hash = calculate_hash([chore_type.id for chore_type in chore_types])
    await crud.rotation.create(
        lang=lang,
        obj_in=Rotation(
            rotation=new_rotation,
            week_id=week_id,
            user_ids_hash=user_ids_hash,
            chore_types_hash=chore_types_hash,
        ),
    )
    return real_chores


async def get_all_weekly_chores(
    missing_only=False, page: int = 1, per_page: int = 10
) -> list[WeeklyChores]:
    users = await crud.user.get_multi()
    chores = await crud.chores.get_multi(per_page=10**3)

    def get_user_name(user_id: str):
        return next(user.username for user in users if user.id == user_id)

    result: list[WeeklyChores] = []
    for week_id, group in groupby(chores, lambda chore: chore.week_id):
        weekly_chores: list[WeeklyChore] = []
        for chore_type, chore_list in groupby(group, lambda x: x.chore_type_id):
            chore_list = list(chore_list)
            weekly_chore = WeeklyChore(
                assigned_ids=[chore.user_id for chore in chore_list],
                assigned_usernames=[
                    get_user_name(chore.user_id) for chore in chore_list
                ],
                done=all([chore.done for chore in chore_list]),
                chore_type_id=chore_type,
            )
            weekly_chores.append(weekly_chore)
        if missing_only is False:
            result.append(WeeklyChores(chores=weekly_chores, week_id=week_id))
        else:
            if all([chore.done for chore in weekly_chores]) is False:
                result.append(WeeklyChores(chores=weekly_chores, week_id=week_id))

    res = result[per_page * (page - 1) : per_page * page]
    return res


async def get_weekly_chores_by_week_id(week_id: str, lang: str) -> WeeklyChores:
    chores = await crud.chores.get_multi(week_id=week_id)
    if not chores:
        throw_no_weekly_chores_found_exception(week_id, lang)
    return await get_weekly_chores_by_chores(chores, week_id)


async def get_weekly_chores_by_chores(
    chores: Sequence[Chore], week_id: str
) -> WeeklyChores:
    users = await crud.user.get_multi()

    def get_user_name(user_id: str):
        return next(user.username for user in users if user.id == user_id)

    weekly_chores: list[WeeklyChore] = []
    for chore_type, chore_list in groupby(chores, lambda x: x.chore_type_id):
        chore_list = list(chore_list)
        weekly_chore = WeeklyChore(
            assigned_ids=[chore.user_id for chore in chore_list],
            assigned_usernames=[get_user_name(chore.user_id) for chore in chore_list],
            done=all([chore.done for chore in chore_list]),
            chore_type_id=chore_type,
        )
        weekly_chores.append(weekly_chore)
    return WeeklyChores(chores=weekly_chores, week_id=week_id)


async def delete_weekly_chores_by_week_id(week_id: str, lang: str):
    chores = await crud.chores.get_multi(week_id=week_id)
    if not chores:
        throw_no_weekly_chores_found_exception(week_id, lang)

    for chore in chores:
        if chore.done:
            detail = i18n.t("weekly_chores.partially_completed", locale=lang)
            raise HTTPException(400, detail)
    for chore in chores:
        await crud.chores.delete(lang=lang, id=chore.id)

    last_rotation = await crud.rotation.get_last_rotation()
    if last_rotation is None:
        raise ValueError("No rotation found")
    await crud.rotation.delete(id=last_rotation.week_id)
